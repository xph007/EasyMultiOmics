# res = heatmap.line.omics(ps01 = ps.16s,psG = ps.ms)
# grid.draw(res[[1]])
# res[[2]]
# res[[3]]
# res[[4]]


micro.point.line.omics = function(ps01 = ps.16s,
                            rank = "Genus",
                            method.scale = "TMM",
                            method.cor = "spearman",
                            ps02 = ps.ms,
                            lab.1 = "16s",
                            lab.2 = "Metabolites",
                            top = 100,
                            cv = 50

){

  id <- ps01 %>%
    ggClusterNet::scale_micro(method = method.scale) %>%
    ggClusterNet::tax_glom_wt(ranks = rank) %>%
    ggClusterNet::filter_OTU_ps(top) %>%
    ggClusterNet::vegan_otu() %>%
    t() %>% as.data.frame() %>%rowCV %>%
    sort(decreasing = TRUE) %>%
    head(cv) %>%
    names()
  id

  ps_rela = ps01 %>%
    ggClusterNet::tax_glom_wt(ranks = rank) %>%
    scale_micro()

  map = phyloseq::sample_data(ps_rela)
  map$ID = row.names(map)
  phyloseq::sample_data(ps_rela) = map
  otu = as.data.frame(t(ggClusterNet::vegan_otu(ps_rela)))
  otu = as.matrix(otu[id,])
  ps_heatm = phyloseq::phyloseq(
    phyloseq::otu_table(otu,taxa_are_rows = TRUE),
    phyloseq::tax_table(ps_rela),
    phyloseq::sample_data(ps_rela)

  )

  # print(ps_heatm)
  datah <- as.data.frame(t(ggClusterNet::vegan_otu(ps_heatm)))
  tax = as.data.frame(ggClusterNet::vegan_tax(ps_heatm))
  otutaxh = cbind(datah,tax)
  otutaxh$id = paste(row.names(otutaxh))
  row.names(otutaxh) = otutaxh$id
  head(otutaxh)
  data <- otutaxh[,c("id",phyloseq::sample_names(ps_rela))]


  rig <- data[,phyloseq::sample_names(ps_rela)] %>% rowMeans() %>% as.data.frame()
  head(rig)
  colnames(rig) = "MeanAbundance"
  rig$id = row.names(rig)
  rig = rig %>% dplyr::arrange(MeanAbundance)
  rig$id = factor(rig$id,levels = rig$id)
  head(rig)
  p_rig = ggplot(rig) + geom_bar(aes(y = id,x = MeanAbundance),
                                 fill = "#A54657",
                                 stat = "identity") + theme_void()


  tem = data[,phyloseq::sample_names(ps_rela)] %>% as.matrix()
  # if (scale == TRUE) {
  tem = scale(t(tem)) %>% t() %>%
    as.data.frame()
  # } else if (scale == FALSE){
  #   tem = tem
  # }

  data[,phyloseq::sample_names(ps_rela)] = tem
  # data[data > 0.3]<-0.3
  mat <- data[,-1] #drop gene column as now in rows

  map = phyloseq::sample_data(ps_rela) %>% as.tibble() %>%
    dplyr::arrange(Group) %>% as.data.frame()
  map$ID

  # tax = ps_rela %>% vegan_tax() %>% as.data.frame()
  # data$id =  tax[,new.id]
  pcm = reshape2::melt(data, id = c("id"))
  pcm$variable = factor(pcm$variable,levels = map$ID)


  # if (ord.col == TRUE) {
  #   pcm$variable = factor(pcm$variable,levels = axis_order.s)
  #
  # }

  pcm$id = factor(pcm$id,levels = rig$id)
  head(pcm)
  pcm1 = pcm
  pcm1$group = lab.1
  # col0 =colorRampPalette(RColorBrewer::brewer.pal(11,"Spectral")[11:1])(60)
  col1 = ggsci::pal_gsea()(12)
  head(pcm1)
  p1 = ggplot(pcm1, aes(y = id, x = variable)) +
    geom_point(aes(size = value,fill = value), alpha = 0.75, shape = 21) +
    # geom_tile(aes(fill = value))+
    # scale_size_continuous(limits = c(0.000001, 100), range = c(2,25), breaks = c(0.1,0.5,1)) +
    labs( y= "", x = "", size = "Relative Abundance (%)", fill = "")  +
    # scale_fill_manual(values = colours, guide = FALSE) +
    scale_x_discrete(limits = rev(levels(pcm$variable)))  +
    scale_y_discrete(position = "left") +
    scale_fill_gradientn(colours =col1)+
    theme(
      panel.background=element_blank(),
      panel.grid=element_blank(),
      axis.text.y = element_text(size = 5),
      axis.text.x = element_text(colour = "black",angle = 90)

    )
  p1



  ps_tem = ps02 %>%
    ggClusterNet::scale_micro()

  id <- ps02 %>%
    ggClusterNet::filter_OTU_ps(top) %>%
    ggClusterNet::vegan_otu() %>%
    t() %>% as.data.frame() %>%rowCV %>%
    sort(decreasing = TRUE) %>%
    head(cv) %>%
    names()
  id

  ps_rela = ps02 %>%
    scale_micro()

  map = phyloseq::sample_data(ps_rela)
  map$ID = row.names(map)
  phyloseq::sample_data(ps_rela) = map
  otu = as.data.frame(t(ggClusterNet::vegan_otu(ps_rela)))
  otu = as.matrix(otu[id,])
  ps_heatm = phyloseq::phyloseq(
    phyloseq::otu_table(otu,taxa_are_rows = TRUE),
    phyloseq::tax_table(ps_rela),
    phyloseq::sample_data(ps_rela)

  )

  # print(ps_heatm)
  datah <- as.data.frame(t(ggClusterNet::vegan_otu(ps_heatm)))
  tax = as.data.frame(ggClusterNet::vegan_tax(ps_heatm))
  otutaxh = cbind(datah,tax)
  otutaxh$id = paste(row.names(otutaxh))
  row.names(otutaxh) = otutaxh$id
  head(otutaxh)
  data <- otutaxh[,c("id",phyloseq::sample_names(ps_rela))]


  rig <- data[,phyloseq::sample_names(ps_rela)] %>% rowMeans() %>% as.data.frame()
  head(rig)
  colnames(rig) = "MeanAbundance"
  rig$id = row.names(rig)
  rig = rig %>% dplyr::arrange(MeanAbundance)
  rig$id = factor(rig$id,levels = rig$id)
  head(rig)
  p_rig = ggplot(rig) + geom_bar(aes(y = id,x = MeanAbundance),
                                 fill = "#A54657",
                                 stat = "identity") + theme_void()


  tem = data[,phyloseq::sample_names(ps_rela)] %>% as.matrix()
  # if (scale == TRUE) {
  tem = scale(t(tem)) %>% t() %>%
    as.data.frame()
  # } else if (scale == FALSE){
  #   tem = tem
  # }

  data[,phyloseq::sample_names(ps_rela)] = tem
  # data[data > 0.3]<-0.3
  mat <- data[,-1] #drop gene column as now in rows

  map = phyloseq::sample_data(ps_rela) %>% as.tibble() %>%
    dplyr::arrange(Group) %>% as.data.frame()

  pcm = reshape2::melt(data, id = c("id"))
  pcm$variable = factor(pcm$variable,levels = map$ID)

  pcm$id = factor(pcm$id,levels = rig$id)
  pcm2 = pcm
  pcm2$group = lab.2
  # col0 =colorRampPalette(RColorBrewer::brewer.pal(11,"Spectral")[11:1])(60)
  col1 = ggsci::pal_gsea()(12)

  p2 = ggplot(pcm2, aes(y = id, x = variable)) +
    geom_point(aes(size = value,fill = value), alpha = 0.75, shape = 21) +
    # geom_tile(aes(fill = value))+
    # scale_size_continuous(limits = c(0.000001, 100), range = c(2,25), breaks = c(0.1,0.5,1)) +
    labs( y= "", x = "", size = "Relative Abundance (%)", fill = "")  +
    # scale_fill_manual(values = colours, guide = FALSE) +
    scale_x_discrete(limits = rev(levels(pcm$variable)))  +
    scale_y_discrete(position = "left") +
    scale_fill_gradientn(colours =col1)+
    theme(
      panel.background=element_blank(),
      panel.grid=element_blank(),
      axis.text.y = element_text(size = 5),
      axis.text.x = element_text(colour = "black",angle = 90)

    )
  p2


  #  联合分面热图
  pcm0 = rbind(pcm1,pcm2)
  head(pcm0)
  pcm0$value %>% min()
  pcm0$value %>% max()
  # library(ggh4x)
  p3 = ggplot(pcm0, aes(y = id, x = variable)) +
    geom_point(aes(fill = value,size = value), alpha = 0.75, shape = 21) +
    # geom_tile(aes(fill = value))+
    # scale_size_continuous( range = c(1,10)) +
    labs( y= "", x = "", size = "Relative Abundance (%)", fill = "")  +
    # scale_fill_manual(values = colours, guide = FALSE) +
    scale_x_discrete(limits = rev(levels(pcm$variable)))  +
    scale_y_discrete(position = "left") +
    scale_fill_gradientn(colours =col1)+
    facet_wrap(.~ group,scales="free_y",nrow = 1) +
    theme(
      panel.background=element_blank(),
      panel.grid=element_blank(),
      legend.position = "top",
      axis.text.y = element_text(size = 5),
      axis.text.x = element_text(colour = "black",angle = 90),
      panel.spacing.x = unit(5, "cm")

    ) +
    ggh4x::facetted_pos_scales(
      y = list(
        group == lab.2 ~ scale_y_discrete(position = "right")
      )
    )


  node4  = add.id.facet(pcm0,"group")
  head(node4)
  node4$group = as.factor(node4$group)

  library(igraph)
  # library("ggalt")
  # library(ggnewscale)
  library(gtable)
  # library(grid)
  # library(igraph)
  # library(sna)
  # library(tidyfst)
  library(grid)
  # library(gtable)

  #  跨域相关性计算
  pst1 = ps01 %>%
    scale_micro() %>%
    ggClusterNet::tax_glom_wt(ranks = rank)

  id <- ps01 %>%
    ggClusterNet::scale_micro(method = method.scale) %>%
    ggClusterNet::tax_glom_wt(ranks = rank) %>%
    ggClusterNet::filter_OTU_ps(top) %>%
    ggClusterNet::vegan_otu() %>%
    t() %>% as.data.frame() %>%rowCV %>%
    sort(decreasing = TRUE) %>%
    head(cv) %>%
    names()
  id
  pst1 = ps01 %>%
    scale_micro() %>%
    ggClusterNet::tax_glom_wt(ranks = rank) %>%
    subset_taxa.wt("OTU",id)
  map = sample_data(pst1)
  map$Group = "A"
  sample_data(pst1) = map


  id <- ps02 %>%
    ggClusterNet::filter_OTU_ps(top) %>%
    ggClusterNet::vegan_otu() %>%
    t() %>% as.data.frame() %>%rowCV %>%
    sort(decreasing = TRUE) %>%
    head(cv) %>%
    names()
  id
  pst2 = ps02 %>%
    ggClusterNet::scale_micro() %>%
    subset_taxa.wt("OTU",id)
  map = sample_data(pst2)
  map$Group = "A"
  sample_data(pst2) = map
  ps.all = merge.ps(ps1 = pst1 ,
                    ps2 = pst2 ,
                    N1 = 0,
                    N2 = 0,
                    scale = FALSE,
                    onlygroup = TRUE,#不进行列合并，只用于区分不同域
                    dat1.lab = lab.1,
                    dat2.lab = lab.2)
  ps.all
  res = corBionetwork.st(
    ps.st= ps.all,# phyloseq对象
    g1 = "Group",# 分组1
    g2 = NULL,# 分组2
    g3 = NULL,# 分组3
    ord.g1 = NULL, # 排序顺序
    ord.g2 = NULL, # 排序顺序
    ord.g3 = NULL, # 排序顺序
    order = NULL, # 出图每行代表的变量
    fill = "filed",
    size = "igraph.degree",method = method.cor,
    clu_method = "cluster_fast_greedy",
    select_layout = TRUE,layout_net = "model_maptree2",
    r.threshold=0.8,
    p.threshold= 0.05,
    maxnode = 5,
    N= 0,
    scale = TRUE,
    env = NULL,
    bio = TRUE,
    minsize = 4,maxsize = 14)

  p4 = res[[1]]
  dat = res[[2]]
  node = dat[[2]]
  edge = dat[[3]]
  head(edge)
  dim(edge)
  edge$from = gsub(paste0("^",lab.1,"_"),"",edge$OTU_2,perl = TRUE)
  edge$to = gsub(paste0("^",lab.2,"_"),"",edge$OTU_1,perl = TRUE)
  head(node4)
  tem = node4$variable %>% levels()
  point.f = tem[1]
  point.r = tem[length(tem)]
  node5 = node4 %>%
    dplyr::filter(variable ==  point.f,group == lab.1)
  head(node5)
  edge1 = edge %>% left_join(node5,by = c("from"="id"))  %>%
    dplyr::rename("id.facet.from" = "id.facet" )
  head(edge1)
  edge1$id.facet.from

  node6 = node4 %>%
    dplyr::filter(variable == point.r,group == lab.2)
  head(node6)

  edge2 = edge1 %>% left_join(node6,by = c("to"="id")) %>%
    dplyr::rename("id.facet.to" = "id.facet" )

  edge2 = edge2 %>%
    dplyr::filter(!is.na(id.facet.from)) %>%
    dplyr::filter(!is.na(id.facet.to))
  dim(edge2)

  edge2$id.facet.to
  edge2$id.facet.from

  g = p3
  for (i in 1:length(edge2$id.facet.from)) {
    id.from = edge2$id.facet.from[i] %>% strsplit( "[_]") %>% sapply(`[`, 2) %>% as.numeric()
    id.to  = edge2$id.facet.to[i] %>% strsplit( "[_]") %>% sapply(`[`, 2)%>% as.numeric()
    g <- line.across.facets.network(g,
                                     from=1, to=2,
                                     from_point_id=id.from,
                                     to_point_id=id.to,
                                     gp=gpar(lty=1, alpha=0.5)
    )
  }

  return(list(g,p1,p2,p3,p4))
}
