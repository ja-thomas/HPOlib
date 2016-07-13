require(ggplot2)

d = read.csv("results.csv")

ggplot(d, aes(optimizer, result, color = time)) +
    scale_colour_gradientn(trans = "log", colours = rainbow(7)) +
    geom_point(size = .7) +
    facet_wrap(~ benchmark, scales = "free") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
ggsave("hpolib.pdf", width = 9, height = 10)
