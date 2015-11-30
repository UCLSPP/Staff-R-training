## 1. Introduction ro R and statistical models
### 1.1 Seminar

<div class="container btn-container">
<button type="button" class="btn btn-info" data-toggle="collapse", data-target="#getting-started">Getting Started</button>
<a href="seminar1.R"><button class="btn btn-primary">Download .R script</button></a>

<button type = "button" class = "btn btn-warning" onclick="location.href='#exercises';">Exercises</button>

</div>

<div id="getting-started" class="collapse">

#### Setting a Working Directory

Before you begin, make sure to set your working directory to a folder where your course related files such as R scripts and datasets are kept. We recommend that you create a `PUBLG100` folder for all your work. Create this folder on N: drive if you're using a UCL computer or somewhere on your local disk if you're using a personal laptop.

Once the folder is created, use the [`setwd()`](http://bit.ly/R_getwd) function in R to set your working directory.

| |Recommended Folder Location|R Function|
|-|-|-|
|UCL Computers|N: Drive|`setwd("N:/PUBLG100")`|
|Personal Laptop (Windows)|C: Drive|`setwd("C:/PUBLG100")`|
|Personal Laptop (Mac)|Home Folder|`setwd("~/PUBLG100")`|

After you've set the working directory, verify it by calling the [`getwd()`](http://bit.ly/R_getwd) function.

```r
getwd()
```

Now download the R script for this seminar from the **"Download .R Script"** button above, and save it to your `PUBLG100` folder.

</div>
<div class="alert alert-warning">
  <i class="glyphicon glyphicon-exclamation-sign"></i>
  <span>If you're using a UCL computer, please make sure you're running R version <strong>3.2.0</strong>. Some of the seminar tasks and exercises will not work with older versions of R. Click [here](../faq/ucl_r.md) for help on how to start the new version of R on UCL computers.</span>
</div>
{% include 'week1/seminar.md' %}
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>

<script src="../js/main.js"></script>

