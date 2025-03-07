wilcox.clr.micro = function(
    ps = ps,
    group =  "Group",
    alpha = 0.05 ){


  map= sample_data(ps)
  head(map)
  id.g = map$Group %>% unique() %>% as.character() %>% combn(2)
  aaa = id.g
  data_list =  list()

  for (i in 1:dim(aaa)[2]) {
    # i = 1
    Desep_group = aaa[,i]
    print( Desep_group)
    ps.cs = ps %>% subset_samples.wt("Group" ,id.g[,i])


  ASV_table = ps.cs %>%
    # subset_samples(Group %in% id.g[,i]) %>%
    vegan_otu() %>% t() %>%
    as.data.frame()
  groupings <-ps.cs %>%
    # subset_samples(Group %in% id.g[,i]) %>%
    sample_data()
  groupings$ID = row.names(groupings)


  #add pseudo count
  CLR_table <- data.frame(apply(ASV_table + 1, 2, function(x){log(x) - mean(log(x))}))
  ## get clr table
  #apply wilcox test to rarified table

  map =  sample_data(ps.cs)
  g = map[,group] %>%
    as.vector() %>% .[[1]] %>% as.factor()
  pvals <- apply(CLR_table, 1, function(x) wilcox.test(x ~ g, exact=FALSE)$p.value)

  dat <- pvals %>% as.data.frame()
  head(dat)
  colnames(dat) = "p"

  tab.d13 = dat %>%
    rownames_to_column(var = "id") %>%
    dplyr::select(id,p) %>%
    dplyr::filter( p < alpha) %>%
    dplyr::rename(
      OTU = id
      # p = p
    )  %>%
    dplyr::mutate(group = " wilcox.test.CLR")

  head(tab.d13)
  res = diff.tab = data.frame(micro = tab.d13$OTU,method = tab.d13$group,
                                   adjust.p = tab.d13$p)

  data_list[[i]]= res

  names( data_list)[i] = Desep_group %>% paste( collapse = "_")

  }
  return(data_list)

}
