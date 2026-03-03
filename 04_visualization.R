# ============================================================
# Stage 4: Visualization & Outputs
# 階段四：視覺化與圖表輸出
# ============================================================

cat("=== Stage 4: Visualization & Outputs ===\n")

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(pROC)   # ROC curve plotting
})

# Load data ----------------------------------------------------
# 讀取 Stage 2 的風險分類資料（作圖使用）
in_path <- "02_clean_data/depression_with_risk_cesd.rds"
if (!file.exists(in_path)) {
  stop("Input file not found: ", in_path,
       "\nPlease run Stage 2 and ensure the file exists.")
}

df <- readRDS(in_path)
cat("Data loaded from:", in_path, "\n")

# Required variables check ------------------------------------
# 檢查作圖所需欄位是否存在
required_vars <- c("風險模式", "憂鬱總分_2025")
missing_vars <- setdiff(required_vars, names(df))
if (length(missing_vars) > 0) {
  stop("Missing required variable(s): ", paste(missing_vars, collapse = ", "))
}

# Output directory --------------------------------------------
# 建立輸出資料夾（若不存在則自動建立）
out_dir <- "04_results"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
cat("Saving figures to:", out_dir, "\n")

# Figure 1: CES-D score distribution by risk pattern ----------
# 圖1：不同風險模式下 2025 CES-D 分數分布（箱形圖）
fig1 <- ggplot(df, aes(x = reorder(風險模式, 憂鬱總分_2025, FUN = median), y = 憂鬱總分_2025)) +
  geom_boxplot(outlier.alpha = 0.4) +
  labs(
    title = "CES-D Scores (2025) by Risk Pattern",
    x = "Risk Pattern",
    y = "CES-D Score (2025)"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

print(fig1)
ggsave(
  filename = file.path(out_dir, "final_plot1_boxplot_cesd2025_by_risk_pattern.png"),
  plot = fig1,
  width = 10, height = 6,
  bg = "white"
)

# Figure 2: Student count by risk pattern ---------------------
# 圖2：各風險模式人數（長條圖）
count_df <- df %>%
  count(風險模式, name = "n") %>%
  arrange(n)

fig2 <- ggplot(count_df, aes(x = reorder(風險模式, n), y = n)) +
  geom_col() +
  geom_text(aes(label = n), vjust = -0.3, size = 3) +
  labs(
    title = "Student Count by Risk Pattern",
    x = "Risk Pattern",
    y = "Number of Students"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
  expand_limits(y = max(count_df$n) * 1.08)

print(fig2)
ggsave(
  filename = file.path(out_dir, "final_plot2_counts_by_risk_pattern.png"),
  plot = fig2,
  width = 10, height = 6,
  bg = "white"
)

# Figure 3: ROC curve (from Stage 3 outputs) ------------------
# 圖3：ROC 曲線（讀取 Stage 3 儲存的 roc 物件）
roc_path <- "03_outputs/roc_depression_worsened.rds"

if (file.exists(roc_path)) {
  cat("\nROC object found. Generating ROC curve...\n")
  roc_obj <- readRDS(roc_path)

  auc_value <- as.numeric(pROC::auc(roc_obj))
  roc_title <- paste0("ROC Curve (AUC = ", round(auc_value, 3), ")")

  # Base plot to PNG (stable & simple for research workflow)
  png(
    filename = file.path(out_dir, "final_plot3_roc_curve.png"),
    width = 1000, height = 700, res = 120, bg = "white"
  )
  plot(roc_obj, main = roc_title)
  abline(a = 0, b = 1, lty = 2)
  dev.off()

  cat("ROC curve saved to: ", file.path(out_dir, "final_plot3_roc_curve.png"), "\n", sep = "")
} else {
  cat("\n[Note] ROC object not found at: ", roc_path, "\n", sep = "")
  cat("      Please run Stage 3 first to generate and save the ROC object.\n")
}

cat("\n✅ Stage 4 completed. Figures saved in: ", out_dir, "\n", sep = "")
