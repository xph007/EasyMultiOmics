

decisiontree.ms <- function(ps=ps, top = 20, seed = 6358, k = 5) {
  set.seed(seed)

  # 数据准备
  ps.cs <- ps %>% filter_OTU_ps(top)
  map <- as.data.frame(phyloseq::sample_data(ps.cs))
  otutab <- as.data.frame(t(ggClusterNet::vegan_otu(ps.cs)))
  colnames(otutab) <- gsub("-", "_", colnames(otutab))
  test <- as.data.frame(t(otutab))
  test$OTUgroup <- factor(map$Group)

  # 初始化结果存储
  accuracy_values <- numeric(k)

  # 创建交叉验证的折
  folds <- createFolds(y = test$OTUgroup, k = k)
  importance_list <- list()
  # 进行交叉验证
  for (i in 1:k) {
    fold_test <- test[folds[[i]], ]
    fold_train <- test[-folds[[i]], ]

    # 训练决策树模型
    a_rpart <- rpart(OTUgroup ~ ., data = fold_train, method = 'class')

    # 得到测试集的预测值
    pred <- predict(a_rpart, newdata = fold_test, type = 'class')

    # 计算准确率
    correct_predictions <- sum(pred == fold_test$OTUgroup)
    accuracy <- correct_predictions / nrow(fold_test)
    accuracy_values[i] <- accuracy


    importance <- a_rpart$variable.importance
    if (!is.null(importance)) {
      importance_list[[i]] <- importance
    }
  }

  # 平均准确率
  mean_accuracy <- mean(accuracy_values)
  accuracy_result <- paste("Decision Tree Accuracy:", round(mean_accuracy, 3))
  print(accuracy_result)

  if (length(importance_list) > 0) {
    combined_importance <- do.call(cbind, importance_list)
    avg_importance <- rowMeans(combined_importance, na.rm = TRUE)
    importance_df <- data.frame(Feature = names(avg_importance), Importance = avg_importance)
    importance_df <- importance_df[order(importance_df$Importance, decreasing = TRUE), ]
  } else {
    importance_df <- data.frame(Feature = character(0), Importance = numeric(0))
  }

  # 返回结果
  list(Accuracy = accuracy_result, Importance = importance_df)
}


