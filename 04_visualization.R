
# 視覺化 - 最終可執行版本
library(ggplot2)
library(dplyr)

# 載入資料
data <- readRDS("02_clean_data/depression_with_risk_cesd.rds")

cat("開始生成圖表...\n")

# 圖1：最簡單的箱形圖
plot1 <- ggplot(data, aes(x = reorder(風險模式, 憂鬱總分_2025), y = 憂鬱總分_2025)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Depression Scores by Risk Group", 
       x = "Risk Group", y = "CES-D Score") +
  theme_bw()  # 使用黑白主題，背景絕對白色

print(plot1)
ggsave("04_results/final_plot1.png", plot1, bg = "white")

# 圖2：最簡單的條形圖
count_data <- data %>% count(風險模式)
plot2 <- ggplot(count_data, aes(x = reorder(風險模式, n), y = n)) +
  geom_col(fill = "lightgreen") +
  geom_text(aes(label = n), vjust = -0.5) +  # 顯示數字
  labs(title = "Student Count by Risk Group",
       x = "Risk Group", y = "Number of Students") +
  theme_bw()

S
ggsave("04_results/final_plot2.png", plot2, bg = "white")

cat("✅ 完成！請檢查 04_results 資料夾中的：\n")
cat("   - final_plot1.png\n")
cat("   - final_plot2.png\n")