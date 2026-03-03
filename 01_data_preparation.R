# ============================================================
# Stage 1: Data Preparation & Initial Inspection
# 階段一：資料讀取與基本檢查
# ============================================================

cat("=== Stage 1: Data Preparation ===\n")

# Load required packages --------------------------------------
# 載入資料處理所需套件
suppressPackageStartupMessages({
  library(haven)      # 用於讀取 SPSS .sav 檔
  library(tidyverse)  # 資料整理與視覺化工具集合
})

# Select and read SPSS file -----------------------------------
# 透過檔案選擇器讀取原始資料
cat("Please select the SPSS (.sav) file...\n")
sav_path <- file.choose()

# 檢查檔案是否存在（避免路徑錯誤）
if (!file.exists(sav_path)) {
  stop("File not found. Please re-run and select a valid .sav file.")
}

# 讀取資料
depression_data <- read_sav(sav_path)

# Basic structural checks -------------------------------------
# 進行資料結構與樣本數基本確認
cat("Data dimensions:", paste(dim(depression_data), collapse = " x "), "\n")
cat("Number of variables:", ncol(depression_data), "\n")
cat("Sample size (rows):", nrow(depression_data), "\n")

# 顯示部分變數名稱（避免過多輸出）
cat("\nVariable names (first 30):\n")
print(names(depression_data)[1:min(30, ncol(depression_data))])

# 預覽前3筆資料（確認資料讀取無誤）
cat("\nPreview (first 3 rows):\n")
print(head(depression_data, 3))

cat("Stage 1 completed: data successfully loaded and inspected.\n")

# Save prepared data ------------------------------------------
# 將原始資料轉為 .rds 格式，供後續分析流程使用
out_dir <- "02_clean_data"
out_path <- file.path(out_dir, "depression_data.rds")

# 若資料夾不存在則自動建立
if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

saveRDS(depression_data, out_path)
cat("Data saved to:", out_path, "\n")
