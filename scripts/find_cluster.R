install.packages("Seurat", repos = "https://cloud.r-project.org/")
install.packages("SeuratDisk", repos = "https://cloud.r-project.org/")

library(Seurat)
library(SeuratDisk)

setwd('/ix/djishnu/Zak/Splenda_study/RNASeq_Raw_Data/ANALYSIS/cell_ranger_2nd_run_tumor/h5_folder/1_percent_gene_thresh/')

combined_seurat <- LoadH5Seurat("TUM_2nd_run.h5seurat")
#combined_seurat = FindVariableFeatures(combined_seurat)
#combined_seurat = ScaleData(combined_seurat, 
   #                               features = VariableFeatures(combined_seurat))

combined_seurat <- FindNeighbors(combined_seurat, 
                                 features=VariableFeatures(combined_seurat),
                                 reduction='pca', dims = 1:11, k.param = 10)
combined_seurat <- FindClusters(combined_seurat)

#results <- FindAllMarkers(combined_seurat, only.pos = TRUE, test.use = 'LR')

#saveRDS(results, file = 'markers_TUM.RDS')
SaveH5Seurat(combined_seurat, filename = 'TUM_2nd_run_clusters', 
             overwrite =TRUE)

#combined_seurat <- LoadH5Seurat("DLN.h5seurat")
#combined_seurat = FindVariableFeatures(combined_seurat)
#combined_seurat = ScaleData(combined_seurat, 
                           # features = VariableFeatures(combined_seurat))

#combined_seurat <- FindNeighbors(combined_seurat, 
#                                 features=VariableFeatures(combined_seurat),
#                                 reduction='pca', dims = 1:11, k.param = 10)
#combined_seurat <- FindClusters(combined_seurat)

#results <- FindAllMarkers(combined_seurat, only.pos = TRUE, test.use = 'LR')

#saveRDS(results, file = 'markers_DLN.RDS')

#SaveH5Seurat(combined_seurat, filename = 'DLN_clusters', 
   #          overwrite =TRUE)