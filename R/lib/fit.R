set.seed(1111)
n <- 1000
y <- rnorm(n, mean=0, sd=1)
y <- exp(y)
hist(y, n=20)
hist(log(y), n=20)

x <- log(y) - rnorm(n, mean=0, sd=1)
hist(x, n=20)

df  <- data.frame(y=y, x=x)
df2 <- data.frame(x=seq(from=min(df$x), to=max(df$x),,100))


#models
mod.name <- "LM"
assign(mod.name, lm(y ~ x, df))
summary(get(mod.name))
plot(y ~ x, df)
lines(predict(get(mod.name), newdata=df2) ~ df2$x, col=2)

mod.name <- "LOG.LM"
assign(mod.name, lm(log(y) ~ x, df))
summary(get(mod.name))
plot(y ~ x, df)
lines(exp(predict(get(mod.name), newdata=df2)) ~ df2$x, col=2)

mod.name <- "LOG.GAUSS.GLM"
assign(mod.name, glm(y ~ x, df, family=gaussian(link="log")))
summary(get(mod.name))
plot(y ~ x, df)
lines(predict(get(mod.name), newdata=df2, type="response") ~ df2$x, col=2)

mod.name <- "LOG.GAMMA.GLM"
assign(mod.name, glm(y ~ x, df, family=Gamma(link="log")))
summary(get(mod.name))
plot(y ~ x, df)
lines(predict(get(mod.name), newdata=df2, type="response") ~ df2$x, col=2)

#Results
model.names <- list("LM", "LOG.LM", "LOG.GAUSS.GLM", "LOG.GAMMA.GLM")

plot(y ~ x, df, log="y", pch=".", cex=3, col=8)
lines(predict(LM, newdata=df2) ~ df2$x, col=1, lwd=2)
lines(exp(predict(LOG.LM, newdata=df2)) ~ df2$x, col=2, lwd=2)
lines(predict(LOG.GAUSS.GLM, newdata=df2, type="response") ~ df2$x, col=3, lwd=2)
lines(predict(LOG.GAMMA.GLM, newdata=df2, type="response") ~ df2$x, col=4, lwd=2)
legend("topleft", legend=model.names, col=1:4, lwd=2, bty="n")

res.AIC <- as.matrix(
    data.frame(
        LM=AIC(LM),
        LOG.LM=AIC(LOG.LM),
        LOG.GAUSS.GLM=AIC(LOG.GAUSS.GLM),
        LOG.GAMMA.GLM=AIC(LOG.GAMMA.GLM)
    )
)

res.SS <- as.matrix(
    data.frame(
        LM=sum((predict(LM)-y)^2),
        LOG.LM=sum((exp(predict(LOG.LM))-y)^2),
        LOG.GAUSS.GLM=sum((predict(LOG.GAUSS.GLM, type="response")-y)^2),
        LOG.GAMMA.GLM=sum((predict(LOG.GAMMA.GLM, type="response")-y)^2)
    )
)

res.RMS <- as.matrix(
    data.frame(
        LM=sqrt(mean((predict(LM)-y)^2)),
        LOG.LM=sqrt(mean((exp(predict(LOG.LM))-y)^2)),
        LOG.GAUSS.GLM=sqrt(mean((predict(LOG.GAUSS.GLM, type="response")-y)^2)),
        LOG.GAMMA.GLM=sqrt(mean((predict(LOG.GAMMA.GLM, type="response")-y)^2))
    )
)

png("stats.png", height=7, width=10, units="in", res=300)
#x11(height=7, width=10)
par(mar=c(10,5,2,1), mfcol=c(1,3), cex=1, ps=12)
barplot(res.AIC, main="AIC", las=2)
barplot(res.SS, main="SS", las=2)
barplot(res.RMS, main="RMS", las=2)
dev.off()

