# 風險分類分析 - CES-D三級切分點版本
cat("=== 階段2: 風險分類（CES-D三級切分點） ===\n")

# 清除並重新載入資料
rm(depression_data)
depression_data <- readRDS("02_clean_data/depression_data.rds")

# 載入套件
library(tidyverse)

# 1. 計算憂鬱變化
cat("計算憂鬱變化...\n")
depression_data <- depression_data %>%
  mutate(
    憂鬱變化 = 憂鬱總分_2025 - 憂鬱總分_2024,
    憂鬱惡化 = ifelse(憂鬱變化 > 0, 1, 0)
  )

# 2. CES-D三級風險模式分類
cat("進行CES-D三級風險分類...\n")
depression_data <- depression_data %>%
  mutate(
    # CES-D三級風險分類（文獻依據）
    基線風險 = case_when(
      憂鬱總分_2024 < 10 ~ "低風險",       # <10分：無明顯症狀
      憂鬱總分_2024 >= 10 & 憂鬱總分_2024 < 21 ~ "中風險",  # 10-20分：輕至中度
      憂鬱總分_2024 >= 21 ~ "高風險"       # ≥21分：嚴重症狀
    ),
    
    # 細緻風險模式分類
    風險模式 = case_when(
      # 高風險模式
      憂鬱總分_2024 >= 21 & 憂鬱總分_2025 >= 21 ~ "持續高風險",
      憂鬱總分_2024 >= 10 & 憂鬱總分_2024 < 21 & 憂鬱總分_2025 >= 21 ~ "中轉高風險",
      憂鬱總分_2024 < 10 & 憂鬱總分_2025 >= 21 ~ "新發高風險",
      
      # 中風險模式
      憂鬱總分_2024 >= 10 & 憂鬱總分_2024 < 21 & 憂鬱總分_2025 >= 10 & 憂鬱總分_2025 < 21 ~ "持續中風險",
      憂鬱總分_2024 < 10 & 憂鬱總分_2025 >= 10 & 憂鬱總分_2025 < 21 ~ "新發中風險",
      
      # 改善與穩定
      憂鬱總分_2024 >= 10 & 憂鬱總分_2025 < 10 ~ "改善至低風險",
      憂鬱總分_2024 < 10 & 憂鬱總分_2025 < 10 ~ "穩定低風險",
      
      TRUE ~ "其他模式"
    )
  )

# 3. 檢查變數
cat("=== 變數檢查 ===\n")
cat("風險模式變數存在:", "風險模式" %in% names(depression_data), "\n")
cat("基線風險變數存在:", "基線風險" %in% names(depression_data), "\n")

# 4. 分析結果
cat("=== CES-D三級切分風險模式分布 ===\n")
risk_table <- table(depression_data$風險模式)
print(risk_table)

cat("\n=== 比例分布(%) ===\n")
print(round(prop.table(risk_table) * 100, 2))

# 5. 基線風險分布
cat("\n=== 基線風險分布（2024年） ===\n")
baseline_table <- table(depression_data$基線風險)
print(baseline_table)
cat("\n基線比例分布(%):\n")
print(round(prop.table(baseline_table) * 100, 2))

# 6. 詳細統計
cat("\n=== 各風險模式詳細統計 ===\n")
risk_summary <- depression_data %>%
  group_by(風險模式) %>%
  summarise(
    人數 = n(),
    比例 = round(n() / nrow(depression_data) * 100, 2),
    平均2024分數 = round(mean(憂鬱總分_2024, na.rm = TRUE), 2),
    平均2025分數 = round(mean(憂鬱總分_2025, na.rm = TRUE), 2),
    平均變化 = round(mean(憂鬱變化, na.rm = TRUE), 2)
  ) %>%
  arrange(desc(平均2025分數))

print(risk_summary)

# 7. 保存結果
saveRDS(depression_data, "02_clean_data/depression_with_risk_cesd.rds")
cat("\n✅ CES-D三級風險分類完成，資料已保存\n")