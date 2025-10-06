# 資料準備與探索
cat("=== 階段1: 資料準備 ===\n")

# 載入套件
library(haven)
library(tidyverse)

# 使用檔案選擇器讀取資料（絕對不會錯）
cat("請選擇憂鬱串連檔.sav檔案...\n")
depression_data <- read_sav(file.choose())

# 基本檢查
cat("資料維度:", dim(depression_data), "\n")
cat("變數名稱:", names(depression_data), "\n")
cat("樣本數:", nrow(depression_data), "\n")

# 顯示前3筆資料確認
cat("\n前3筆資料:\n")
print(head(depression_data, 3))

cat("✅ 資料準備完成\n")

# 保存路徑供後續使用
saveRDS(depression_data, "02_clean_data/depression_data.rds")
cat("資料已保存至: 02_clean_data/depression_data.rds\n")