library(tidyverse)

full_d <- read_tsv(snakemake@input[[1]],
                   col_names = c("type", "count"),
                   col_types = "cd")

pairtype_d <- full_d %>% filter(str_detect(type, "^pair_types")) %>%
  rename(pairtype = type) %>%
  mutate(pairtype = str_remove(pairtype, "^pair_types/"))

chrom_freq_d <- full_d %>% filter(str_detect(type, "^chrom_freq")) %>%
  rename(chrom_pair = type) %>%
  mutate(chrom_pair = str_remove(chrom_pair, "^chrom_freq/"))

dist_freq_d <- full_d %>% filter(str_detect(type, "^dist_freq")) %>%
  rename(interval = type) %>%
  mutate(interval = str_remove(interval, "^dist_freq/"))

basic_stats <- full_d %>% filter(
  !str_detect(type, "^pair_types"),
  !str_detect(type, "^chrom_freq"),
  !str_detect(type, "^dist_freq")
) %>%
  pivot_wider(names_from = type, values_from = count) %>%
  mutate(valid_read_pairs = trans + `cis_1kb+`) %>%
  pivot_longer(everything(), names_to = "type", values_to = "count") %>%
  mutate(type = factor(type, levels = c(
    "total",
    "total_unmapped",
    "total_single_sided_mapped",
    "total_mapped",
    "total_dups",
    "total_nodups",
    "cis",
    "trans",
    "cis_1kb+",
    "cis_2kb+",
    "cis_4kb+",
    "cis_10kb+",
    "cis_20kb+",
    "cis_40kb+",
    "valid_read_pairs"
  )))

category_bars <- ggplot(basic_stats, aes(count, fct_rev(type))) +
  geom_col() +
  geom_text(aes(label = str_c(format(percent_of_total, digits = 2, trim = TRUE), "%")),
            data = basic_stats %>%
              group_by(type) %>%
              summarise(count = sum(count), .groups = "drop") %>%
              mutate(percent_of_total = 100 * count / count[type == "total"]),
            hjust = -.1) +
  scale_x_continuous(labels = function(x) x / 1e6,
                     limits = c(0, max(basic_stats$count) * 1.2)) +
  labs(x = "Number of read pairs (millions)",
       y = "Category",
       title = str_c("Min MAPQ: ", snakemake@wildcards[["min_mapq"]]),
       fill = "Sample")

ggsave(snakemake@output[[1]],
       plot = category_bars)
