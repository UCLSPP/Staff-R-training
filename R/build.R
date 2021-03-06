# script called by Makefile for integration with RStudio

clean <- function() { Rgitbook::cleanGitbook() }
open <- function() {  Rgitbook::openGitbook() }
publish <- function() { Rgitbook::publishGitbook() }

args <- commandArgs(TRUE)
stopifnot(length(args) >= 1)

build <- function() { 
  outline <- read.csv("outline.csv", header=TRUE, colClasses = c("integer", "logical", "logical", "character"))
  r_header <- readLines("common/r_header.txt")

  purl_folder <- function(path) {
    week <- as.integer(stringr::str_match(path, "^week(\\d{1,2}$)")[2])
    topic <- stringr::str_trim(outline$Topic[week])

    purl_file <- function(filename) {
      purl_output <- tempfile()
      knitr::purl(filename, output = purl_output, documentation = 1, quiet = TRUE)
      
      type <- R.utils::capitalize(sub("\\.Rmd$", "", basename(filename)))
      r_file <- sub("\\.Rmd$", paste0(week, ".R"), filename, ignore.case = TRUE)
      
      write(r_header, file = r_file)
      
      write(paste0("# Week ", week, " ", type, ": ", topic), file = r_file, append = TRUE)
      write("#\n#\n", file = r_file, append = TRUE)

      common_r_header <- file.path("common", paste0(tolower(type), ".R"))
      if (file.exists(common_r_header))
        write(readLines(common_r_header), file = r_file, append = TRUE)
      
      write(readLines(purl_output), file = r_file, append = TRUE)
    }
    lapply(list.files(path = path, pattern = "(seminar|solutions)\\.Rmd$", full.names = TRUE), purl_file)
  }
  
  lapply(list.files(pattern = "^week\\d{1,2}$"), purl_folder)
  Rgitbook::buildGitbook() 
}

do.call(args[1], args=list())
