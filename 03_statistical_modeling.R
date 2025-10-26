# 03_binary_logistic_modeling.R
# 憂鬱惡化二元預測模型

# 載入所需套件
library(dplyr)
library(pROC)

# 載入清理後的資料
load("data/processed/cleaned_mental_health_data.RData")

message("=== 憂鬱惡化二元預測模型 ===")

# 1. 建立憂鬱惡化二元變項 ----
message("1. 建立憂鬱惡化二元變項...")

analysis_data <- cleaned_data %>%
  mutate(
    # 將憂鬱變化轉為二元變項：1=惡化, 0=沒有惡化
    depression_worsened = ifelse(depression_change == "Worsened", 1, 0)
  )

# 確認轉換成功
message("憂鬱變化轉換檢查:")
table(原分類 = analysis_data$depression_change, 新二元 = analysis_data$depression_worsened)

# 查看資料前幾筆
message("前6筆資料預覽:")
head(analysis_data %>% select(student_id, depression_change, depression_worsened))

# 2. 建立憂鬱惡化預測模型 ----
message("2. 建立憂鬱惡化預測模型...")

model <- glm(depression_worsened ~ family_cohesion_change + parent_relationship_change + 
               coping_strategy + sleep_pattern_change + self_esteem_change + 
               life_stress_events + academic_stress + gender,
             data = analysis_data, family = binomial)

# 顯示模型摘要
message("=== 憂鬱惡化預測模型結果 ===")
summary(model)

# 修正版本的模型評估部分
message("3. 模型評估...")

# 取得沒有缺失值的資料索引
complete_cases <- complete.cases(analysis_data[, c("family_cohesion_change", "parent_relationship_change", 
                                                   "coping_strategy", "sleep_pattern_change", 
                                                   "self_esteem_change", "life_stress_events", 
                                                   "academic_stress", "gender")])

# 只對完整資料進行預測
analysis_complete <- analysis_data[complete_cases, ]
predictions <- ifelse(predict(model, type = "response") > 0.5, 1, 0)
accuracy <- mean(predictions == analysis_complete$depression_worsened)

message("模型預測準確率:", round(accuracy * 100, 2), "%")

# 混淆矩陣
message("混淆矩陣:")
conf_matrix <- table(實際 = analysis_complete$depression_worsened, 預測 = predictions)
print(conf_matrix)

# 4. 尋找最佳閾值 ----
message("4. 尋找最佳預測閾值...")

roc_obj <- roc(analysis_complete$depression_worsened, predict(model, type = "response"))
best_threshold <- coords(roc_obj, "best")$threshold

message("最佳預測閾值:", round(best_threshold, 3))

# 使用最佳閾值重新預測
predictions_optimized <- ifelse(predict(model, type = "response") > best_threshold, 1, 0)
optimized_accuracy <- mean(predictions_optimized == analysis_complete$depression_worsened)

message("優化後準確率:", round(optimized_accuracy * 100, 2), "%")

message("優化後混淆矩陣:")
optimized_conf_matrix <- table(實際 = analysis_complete$depression_worsened, 優化預測 = predictions_optimized)
print(optimized_conf_matrix)

# 5. AUC 分析 ----
message("5. 模型辨識能力分析...")

auc_value <- auc(roc_obj)
message("ROC曲線下面積 (AUC):", round(auc_value, 3))

# AUC 解讀指南
message("AUC 解讀:")
if(auc_value >= 0.9) {
  message("極佳的辨識能力 (A+)")
} else if(auc_value >= 0.8) {
  message("良好的辨識能力 (A)") 
} else if(auc_value >= 0.7) {
  message("不錯的辨識能力 (B+)")
} else if(auc_value >= 0.6) {
  message("一般的辨識能力 (C)")
} else {
  message("辨識能力有待改進 (D)")
}
