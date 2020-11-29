
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/threesixtygiving)](https://cran.r-project.org/package=threesixtygiving)
[![GitHub
tag](https://img.shields.io/github/tag/evanodell/threesixtygiving.svg)](https://github.com/evanodell/threesixtygiving)
[![](https://cranlogs.r-pkg.org/badges/grand-total/threesixtygiving)](https://dgrtwo.shinyapps.io/cranview/)
[![R build
status](https://github.com/evanodell/threesixtygiving/workflows/R-CMD-check/badge.svg)](https://github.com/evanodell/threesixtygiving/actions)
[![Codecov test
coverage](https://codecov.io/gh/evanodell/threesixtygiving/branch/master/graph/badge.svg)](https://codecov.io/gh/evanodell/threesixtygiving?branch=master)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/evanodell/threesixtygiving?branch=master&svg=true)](https://ci.appveyor.com/project/evanodell/threesixtygiving)
[![DOI](https://zenodo.org/badge/195080045.svg)](https://zenodo.org/badge/latestdoi/195080045)
<!-- badges: end -->

# threesixtygiving

Access open data from [360Giving](https://www.threesixtygiving.org/)
publishers. 360Giving is a data standard for publishing information
about charitable grant giving in the UK. 360Giving maintains a [registry
of grant makers](https://data.threesixtygiving.org/) using the standard.
The package provides functions to search and retrieve data on charitable
giving.

## Installation

<!--
You can install the released version of threesixtygiving from [CRAN](https://CRAN.R-project.org) with:
``` r
install.packages("threesixtygiving")
```
-->

You can install the development version from
[GitHub](https://github.com/evanodell/threesixtygiving) with:

``` r
# install.packages("devtools")
devtools::install_github("evanodell/threesixtygiving")
```

## Purpose

The `threesixtygiving` package provides tools for programmatically
downloading and analysing grants made by charitable trusts using the
[360Giving standard](https://standard.threesixtygiving.org/). These
include functions to search available datasets, retrieve data and
process it to tidy formats.

## Usage

The example below shows how to retrieve all available grants, and
presents the total value of grants since 2018-01-01. It uses the
[`fixerapi`](https://cran.r-project.org/package=fixerapi) package to
perform currency conversions, as some grants are reported in currencies
other than GBP.

``` r
library(threesixtygiving)
library(dplyr)
library(ggplot2)
library(fixerapi) # for currency rates
library(stringi)

grants <- tsg_all_grants(timeout = 8, retries = 0)

df <- tsg_core_data(grants)

# Retrieve currency exchange rates
currencies <- fixer_latest("EUR", c(unique(df$currency)))

# Convert exchange rates to use GBP as the base currencies
currencies <- currencies %>% 
  mutate(value = value * (1/currencies$value[currencies$name == "GBP"]))

currencies

## rate on 2020-11-28
df2 <- df %>% 
  mutate(amount_awarded = case_when(
    currency == "USD" ~ amount_awarded/filter(currencies, name=="USD")$value,
    currency == "CAD" ~ amount_awarded/filter(currencies, name=="CAD")$value,
    currency == "CHF" ~ amount_awarded/filter(currencies, name=="CHF")$value,
    currency == "EUR" ~ amount_awarded/filter(currencies, name=="EUR")$value,
    currency == "ILS" ~ amount_awarded/filter(currencies, name=="ILS")$value,
    TRUE ~ amount_awarded)) %>%
  filter(award_date >= "2018-01-01") %>%
  group_by(funding_org_name) %>%
  summarise(n = n(),
            amount_awarded = sum(amount_awarded)) %>%
  mutate(avg = amount_awarded/n)

theme_set(theme_bw())

p1 <- ggplot(df2 %>% 
               top_n(20, amount_awarded) %>% 
               mutate(amount_awarded2 = amount_awarded/100000),
             aes(x = reorder(funding_org_name, -amount_awarded2),
                 y = amount_awarded2, fill = amount_awarded2)) + 
  geom_col() + 
  scale_y_sqrt(labels = scales::dollar_format(prefix = "£"),
               breaks = c(1000, 5000, 10000, 25000, 50000, 75000)) + 
  scale_x_discrete(labels = scales::wrap_format(40)) + 
  scale_fill_viridis_c() + 
  labs(x = "Funder", y = "Amount Awarded 
       (in 100,000s, note logarithmic scale)",
       title = "Total Value of Grants Awarded by Twenty Largest Funders",
       caption = "(c) Evan Odell | 2020 | CC-BY-SA | Data from 360Giving") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 7),
        legend.position = "none") 
  
p1

#ggsave("man/figures/total-value.png", p1, width = 10)
```

![](man/figures/total-value.png)

## Notes

This project is possible thanks to support and encouragement from David
Kane at [360Giving](https://www.threesixtygiving.org/), and from
[Disability Rights UK](https://www.disabilityrightsuk.org/).

### Data licences

The actual grant data is available under a variety of open licences,
typically a version of the Open Government Licence or one of the
Creative Commons licences. Please respect the licence conditions that
are attached to each dataset.

### Citing `threesixtygiving`

Please cite `threesixtygiving` as:

Odell, Evan (2020). *threesixtygiving: Download Charitable Grants from
the ‘360Giving’ Platform*. doi:
[10.5281/zenodo.3474128](https://doi.org/10.5281/zenodo.3474128), R
package version 0.2.2, URL:
<https://docs.evanodell.com/threesixtygiving>.

A BibTeX entry for LaTeX users is:

      @Manual{,
        title = {threesixtygiving: Download Charitable Grants from the '360Giving' Platform},
        author = {Evan Odell},
        year = {2020},
        doi = {10.5281/zenodo.3474128},
        url = {https://docs.evanodell.com/threesixtygiving},
        note = {R package version 0.2.2},
      }

### Code of Conduct

Please note that the `threesixtygiving` package is released with a
[Contributor Code of
Conduct](https://github.com/evanodell/threesixtygiving/blob/master/CODE_OF_CONDUCT.md).
By contributing to this project, you agree to abide by its terms.

The code in this package is licensed using the [GNU General Public
License Version 3](https://www.gnu.org/licenses/gpl-3.0) software
license.
