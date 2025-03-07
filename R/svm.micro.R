svm.micro <- function(ps=ps, k = 5) {
  # 数据准备
  map <- as.data.frame(phyloseq::sample_data(ps))
  otutab <- as.data.frame(t(ggClusterNet::vegan_otu(ps)))
  colnames(otutab) <- gsub("-", "_", colnames(otutab))
  test <- as.data.frame(t(otutab))
  test$group <- factor(map$Group)
  colnames(test) <- paste("OTU", colnames(test), sep = "")

  colnames(test) <- gsub("-", "_", colnames(test))
  colnames(test) <- gsub("[/]", "_", colnames(test))
  colnames(test) <- gsub("[(]", "_", colnames(test))
  colnames(test) <- gsub("[)]", "_", colnames(test))
  colnames(test) <- gsub("[:]", "_", colnames(test))
  colnames(test) <- gsub("[[]", "", colnames(test))
  colnames(test) <- gsub("[]]", "_", colnames(test))
  colnames(test) <- gsub("[#]", "_", colnames(test))
  colnames(test) <- gsub("[+]", "_", colnames(test))
  colnames(test) <- gsub(" ", "_", colnames(test))

  test <- dplyr::select(test, OTUgroup, everything())
  train <- test

  folds <- createFolds(y = test$OTUgroup, k = k)

  fc <- as.numeric()
  mod_pre <- as.numeric()
  accuracy_values <- numeric(k)

  for(i in 1:5){
    fold_test<-train[folds[[i]],]
    # head(fold_test)
    fold_train<-train[-folds[[i]],]
    model<-svm(OTUgroup~.,data=fold_train,probability=TRUE)
    model
    model_pre<-predict(model,newdata = fold_test,decision.values = TRUE, probability = TRUE)
    fc<-append(fc,as.numeric(fold_test$OTUgroup))
    mod_pre<-append(mod_pre,as.numeric(attr(model_pre, "probabilities")[,2]))

    # 计算准确率
    correct_predictions <- sum( model_pre == fold_test$OTUgroup)
    accuracy <- correct_predictions / nrow(fold_test)
    accuracy_values[i] <- accuracy
    # print(paste("Fold", i, "Accuracy:", round(accuracy, 3)))



  }

  # # 计算AUC
  # pred <- prediction(mod_pre, fc)
  # auc <- performance(pred, "auc")@y.values[[1]]
  # auc_result <- paste("SVM AUC:", round(auc, 3))

  # 特征重要性评估（RFE）
  control <- rfeControl(functions = caretFuncs, method = "cv", number = k)
  rfe_results <- rfe(train[, -1], train$OTUgroup, sizes = c(1:ncol(train) - 1), rfeControl = control)
  importance <- varImp(rfe_results, scale = FALSE)


  mean_accuracy <- mean(accuracy_values)
  accuracy_result <- paste("SVM Average Accuracy:", round(mean_accuracy, 3))
  row.names(importance) =  gsub("OTU","",row.names(importance))
  # 输出结果
  list(AUC = accuracy_result, Importance = importance)
}
