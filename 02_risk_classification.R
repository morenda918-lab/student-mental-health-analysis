# ============================================================
# Stage 2: Risk Classification (CES-D 3-level cutoffs)
# 階段二：CES-D 三級切分點之風險分類
# ============================================================

cat("=== Stage 2: Risk Classification (CES-D 3-level cutoffs) ===\n")

# Load required packages --------------------------------------
# 載入資料整理套件（本階段主要使用 dplyr / tidyr）
suppressPackageStartupMessages({
  library(tidyverse)
})

# Load data ----------------------------------------------------
# 讀取前一階段輸出的 .rds（避免直接依賴原始檔）
in_path <- "02_clean_data/depression_data.rds"
if (!file.exists(in_path)) {
  stop("Input file not found: ", in_path,
       "\nPlease run Stage 1 and ensure the file exists.")
}

depression_data <- readRDS(in_path)
cat("Data loaded from:", in_path, "\n")

# Required variables check ------------------------------------
# 檢查必要欄位是否存在（確保可重現與避免靜默錯誤）
required_vars <- c("憂鬱總分_2024", "憂鬱總分_2025")
missing_vars <- setdiff(required_vars, names(depression_data))
if (length(missing_vars) > 0) {
  stop("Missing required variables: ", paste(missing_vars, collapse = ", "))
}

# Compute depression change -----------------------------------
# 計算憂鬱變化（2025 - 2024）；並建立是否惡化之指標
cat("Computing change scores...\n")
depression_data <- depression_data %>%
  mutate(
    憂鬱變化 = 憂鬱總分_2025 - 憂鬱總分_2024,
    憂鬱惡化 = case_when(
      is.na(憂鬱變化) ~ NA_integer_,
      憂鬱變化 > 0 ~ 1L,
      TRUE ~ 0L
    )
  )

# CES-D baseline risk (3-level cutoffs) -----------------------
# CES-D 三級切分（<10 低；10-20 中；≥21 高）
cat("Assigning baseline risk groups (CES-D cutoffs)...\n")
depression_data <- depression_data %>%
  mutate(
    基線風險 = case_when(
      is.na(憂鬱總分_2024) ~ NA_character_,
      憂鬱總分_2024 < 10 ~ "Low risk",
      憂鬱總分_2024 >= 10 & 憂鬱總分_2024 < 21 ~ "Moderate risk",
      憂鬱總分_2024 >= 21 ~ "High risk"
    )
  )

# Risk pattern classification ---------------------------------
# 風險模式：依 2024/2025 分數落點組合進行分類
cat("Classifying risk patterns...\n")
depression_data <- depression_data %>%
  mutate(
    風險模式 = case_when(
      # If either year is missing, keep NA (avoid misclassification)
      is.na(憂鬱總分_2024) | is.na(憂鬱總分_2025) ~ NA_character_,

      # High-risk patterns
      憂鬱總分_2024 >= 21 & 憂鬱總分_2025 >= 21 ~ "Persistent high risk",
      憂鬱總分_2024 >= 10 & 憂鬱總分_2024 < 21 & 憂鬱總分_2025 >= 21 ~ "Escalated to high risk",
      憂鬱總分_2024 < 10 & 憂鬱總分_2025 >= 21 ~ "New onset high risk",

      # Moderate-risk patterns
      憂鬱總分_2024 >= 10 & 憂鬱總分_2024 < 21 &
        憂鬱總分_2025 >= 10 & 憂鬱總分_2025 < 21 ~ "Persistent moderate risk",
      憂鬱總分_2024 < 10 & 憂鬱總分_2025 >= 10 & 憂鬱總分_2025 < 21 ~ "New onset moderate risk",

      # Improvement / stability
      憂鬱總分_2024 >= 10 & 憂鬱總分_2025 < 10 ~ "Improved to low risk",
      憂鬱總分_2024 < 10 & 憂鬱總分_2025 < 10 ~ "Stable low risk",

      TRUE ~ "Other"
    )
  )

# Quick verification ------------------------------------------
# 快速檢查新變項是否建立成功
cat("\n=== Variable check ===\n")
cat("Has risk_pattern (風險模式):", "風險模式" %in% names(depression_data), "\n")
cat("Has baseline_risk (基線風險):", "基線風險" %in% names(depression_data), "\n")

# Distribution tables -----------------------------------------
# 風險模式與基線風險分布（含比例）
cat("\n=== Risk pattern distribution ===\n")
risk_table <- table(depression_data$風險模式, useNA = "ifany")
print(risk_table)

cat("\n=== Proportions (%) ===\n")
print(round(prop.table(risk_table) * 100, 2))

cat("\n=== Baseline risk distribution (2024) ===\n")
baseline_table <- table(depression_data$基線風險, useNA = "ifany")
print(baseline_table)

cat("\n=== Baseline proportions (%) ===\n")
print(round(prop.table(baseline_table) * 100, 2))

# Summary statistics by risk pattern ---------------------------
# 各風險模式之描述統計（人數、比例、平均分數與變化）
cat("\n=== Summary by risk pattern ===\n")
risk_summary <- depression_data %>%
  group_by(風險模式) %>%
  summarise(
    n = n(),
    pct = round(n / nrow(depression_data) * 100, 2),
    mean_2024 = round(mean(憂鬱總分_2024, na.rm = TRUE), 2),
    mean_2025 = round(mean(憂鬱總分_2025, na.rm = TRUE), 2),
    mean_change = round(mean(憂鬱變化, na.rm = TRUE), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_2025))

print(risk_summary)

# Save output --------------------------------------------------
# 輸出含風險分類之資料集，供後續建模使用
out_path <- "02_clean_data/depression_with_risk_cesd.rds"
saveRDS(depression_data, out_path)

cat("\n✅ Stage 2 completed: risk classification saved to: ", out_path, "\n", sep = "")
