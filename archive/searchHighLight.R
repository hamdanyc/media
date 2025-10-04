library(DT)
mtcars2 = head(mtcars[, 1:5], 20)
mtcars2$model = rownames(mtcars2)
rownames(mtcars2) = NULL
options(DT.options = list(pageLength = 5))
# global search
datatable(mtcars2, options = list(searchHighlight = TRUE, search = list(search = 'da')))
