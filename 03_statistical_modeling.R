# ============================================================
# Stage 3: Binary Logistic Modeling (Depression Worsening)
# 階段三：二元邏輯斯迴歸（憂鬱惡化預測）
# ============================================================

cat("=== Stage 3: Binary Logistic Modeling (Depression Worsening) ===\n")

# Load required packages --------------------------------------
# 載入建模與 ROC 評估套件
suppressPackageStartupMessages({
  library(dplyr)
  library(pROC)
})

# Load processed data -----------------------------------------
# 讀取已清理之資料（請確認 cleaned_data 物件存在於 .RData）
in_path <- "data/processed/cleaned_mental_health_data.RData"
if (!file.exists(in_path)) {
  stop("Input file not found: ", in_path,
       "\nPlease ensure the processed data file exists.")
}
load(in_path)

if (!exists("cleaned_data")) {
  stop("Object 'cleaned_data' not found in the loaded .RData file.")
}

cat("Data loaded from:", in_path, "\n")
cat("Rows:", nrow(cleaned_data), " | Variables:", ncol(cleaned_data), "\n")

# 1) Create binary outcome ------------------------------------
# 依原分類建立二元結果變項（1=惡化, 0=未惡化）
cat("\n[1] Creating binary outcome...\n")

required_outcome_vars <- c("depression_change")
missing_outcome_vars <- setdiff(required_outcome_vars, names(cleaned_data))
if (length(missing_outcome_vars) > 0) {
  stop("Missing required variable(s): ", paste(missing_outcome_vars, collapse = ", "))
}

analysis_data <- cleaned_data %>%
  mutate(
    depression_worsened = case_when(
      is.na(depression_change) ~ NA_integer_,
      depression_change == "Worsened" ~ 1L,
      TRUE ~ 0L
    )
  )

cat("Outcome check (original vs binary):\n")
print(table(original = analysis_data$depression_change,
            binary = analysis_data$depression_worsened,
            useNA = "ifany"))

cat("\nPreview (first 6 rows):\n")
# 若 student_id 不存在就略過避免報錯
preview_cols <- intersect(c("student_id", "depression_change", "depression_worsened"), names(analysis_data))
print(head(analysis_data[, preview_cols, drop = FALSE], 6))

# 2) Fit logistic regression model ----------------------------
# 建立邏輯斯迴歸模型（以可解釋性為優先，適用政策溝通）
cat("\n[2] Fitting logistic regression model...\n")

predictors <- c(
  "family_cohesion_change",
  "parent_relationship_change",
  "coping_strategy",
  "sleep_pattern_change",
  "self_esteem_change",
  "life_stress_events",
  "academic_stress",
  "gender"
)

missing_pred <- setdiff(predictors, names(analysis_data))
if (length(missing_pred) > 0) {
  stop("Missing predictor(s): ", paste(missing_pred, collapse = ", "))
}

# 僅保留 outcome + predictors 並一致性處理缺失值（避免模型/評估資料不一致）
model_df <- analysis_data %>%
  select(depression_worsened, all_of(predictors)) %>%
  filter(!is.na(depression_worsened)) %>%
  na.omit()

cat("Modeling rows after NA handling:", nrow(model_df), "\n")
cat("Outcome distribution (after NA handling):\n")
print(table(model_df$depression_worsened))

model <- glm(
  depression_worsened ~ family_cohesion_change + parent_relationship_change +
    coping_strategy + sleep_pattern_change + self_esteem_change +
    life_stress_events + academic_stress + gender,
  data = model_df,
  family = binomial
)

cat("\n=== Model Summary ===\n")
print(summary(model))

# 3) Model evaluation -----------------------------------------
# 以同一份 model_df 進行預測與評估（確保資料長度一致）
cat("\n[3] Model evaluation...\n")

pred_prob <- predict(model, newdata = model_df, type = "response")

# Default threshold = 0.5
threshold_default <- 0.5
pred_class_default <- ifelse(pred_prob > threshold_default, 1L, 0L)

acc_default <- mean(pred_class_default == model_df$depression_worsened)
cat("Accuracy (threshold = 0.5):", round(acc_default * 100, 2), "%\n")

cat("\nConfusion matrix (threshold = 0.5):\n")
print(table(actual = model_df$depression_worsened, predicted = pred_class_default))

# 4) Optimal threshold via ROC --------------------------------
# ROC 尋找最佳閾值（以 best 方法；適用於成本不對稱未明確時的基準比較）
cat("\n[4] Finding optimal threshold (ROC-based)...\n")

roc_obj <- roc(
  response = model_df$depression_worsened,
  predictor = pred_prob,
  quiet = TRUE
)

best_coords <- coords(roc_obj, "best", ret = c("threshold", "sensitivity", "specificity"))
best_threshold <- as.numeric(best_coords["threshold"])

cat("Best threshold:", round(best_threshold, 3), "\n")
cat("Sensitivity:", round(as.numeric(best_coords["sensitivity"]), 3),
    " | Specificity:", round(as.numeric(best_coords["specificity"]), 3), "\n")

pred_class_opt <- ifelse(pred_prob > best_threshold, 1L, 0L)
acc_opt <- mean(pred_class_opt == model_df$depression_worsened)

cat("Accuracy (optimal threshold):", round(acc_opt * 100, 2), "%\n")
cat("\nConfusion matrix (optimal threshold):\n")
print(table(actual = model_df$depression_worsened, predicted = pred_class_opt))

# 5) AUC -------------------------------------------------------
# AUC 作為整體辨識能力指標（與閾值無關）
cat("\n[5] Discrimination (AUC)...\n")

auc_value <- as.numeric(auc(roc_obj))
cat("AUC:", round(auc_value, 3), "\n")

# AUC interpretation (research-style, non-inflated wording)
cat("AUC interpretation:\n")
if (auc_value >= 0.90) {
  cat("Excellent discrimination.\n")
} else if (auc_value >= 0.80) {
  cat("Good discrimination.\n")
} else if (auc_value >= 0.70) {
  cat("Fair discrimination.\n")
} else if (auc_value >= 0.60) {
  cat("Poor-to-fair discrimination.\n")
} else {
  cat("Limited discrimination; model improvement may be needed.\n")
}

# Optional: save outputs --------------------------------------
# （選用）輸出模型與 ROC 物件，供後續視覺化與報告使用
out_dir <- "03_outputs"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

saveRDS(model, file.path(out_dir, "logistic_model_depression_worsened.rds"))
saveRDS(roc_obj, file.path(out_dir, "roc_depression_worsened.rds"))

cat("\n✅ Stage 3 completed: model and ROC objects saved to ", out_dir, "\n", sep = "")
