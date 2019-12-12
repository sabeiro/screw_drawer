summary <- function (object, ..., digits = max(3L, getOption("digits") -
    3L))
{
    if (is.factor(object))
        return(summary.factor(object, ...))
    else if (is.matrix(object))
        return(summary.matrix(object, digits = digits, ...))
    value <- if (is.logical(object))
        c(Mode = "logical", {
            tb <- table(object, exclude = NULL)
            if (!is.null(n <- dimnames(tb)[[1L]]) && any(iN <- is.na(n))) dimnames(tb)[[1L]][iN] <- "NA's"
            tb
        })
    else if (is.numeric(object)) {
        nas <- is.na(object)
        object <- object[!nas]
        qq <- stats::quantile(object)
        qq <- signif(c(qq[1L:3L], mean(object), qq[4L:5L]), digits)
        names(qq) <- c("Min.", "1st Qu.", "Median", "Mean", "3rd Qu.",
            "Max.")
        if (any(nas))
            c(qq, `NA's` = sum(nas))
        else qq
    }
    else if (is.recursive(object) && !is.language(object) &&
        (n <- length(object))) {
        sumry <- array("", c(n, 3L), list(names(object), c("Length",
            "Class", "Mode")))
        ll <- numeric(n)
        for (i in 1L:n) {
            ii <- object[[i]]
            ll[i] <- length(ii)
            cls <- oldClass(ii)
            sumry[i, 2L] <- if (length(cls))
                cls[1L]
            else "-none-"
            sumry[i, 3L] <- mode(ii)
        }
        sumry[, 1L] <- format(as.integer(ll))
        sumry
    }
    else c(Length = length(object), Class = class(object), Mode = mode(object))
    class(value) <- c("summaryDefault", "table")
    value
}
