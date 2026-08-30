library(ape)
library(ggtree)
library(ggplot2)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

tree_file <- if (length(args) >= 1) args[1] else "results/assembly_based/parsnp/parsnp.tree"
output_file <- if (length(args) >= 2) args[2] else "figures/parsnp_phylogeny.png"

tree <- read.tree(tree_file)

tree$tip.label <- sub(".*(E[0-9]+).*", "\\1", tree$tip.label)

tree_dist <- cophenetic.phylo(tree)

hc <- hclust(
    as.dist(tree_dist),
    method = "average"
)

clusters <- cutree(
    hc,
    h = 0.005
)

cluster_df <- data.frame(
    label = names(clusters),
    cluster = factor(clusters)
) %>%
    group_by(cluster) %>%
    mutate(
        group_size = n(),
        status = ifelse(
            group_size > 1,
            "Outbreak-like",
            "Sporadic"
        )
    ) %>%
    ungroup()

plot <- ggtree(tree, size = 0.6) %<+% cluster_df +
    geom_tippoint(
        aes(color = status, shape = status),
        size = 3
    ) +
    geom_tiplab(
        aes(label = label),
        size = 2.5,
        offset = 0.005
    ) +
    theme_tree2() +
    labs(
        title = "ParSNP Core-Genome Phylogeny"
    )

dir.create(
    dirname(output_file),
    recursive = TRUE,
    showWarnings = FALSE
)

ggsave(
    filename = output_file,
    plot = plot,
    width = 10,
    height = 8,
    dpi = 350
)
