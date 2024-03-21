SLIDEcv <- function(yaml_path=NULL,nrep=20,k=10){
  library(SLIDE)
  library(ggplot2)
  library(doParallel)
  
  if(is.null(yaml_path)){stop("yaml path can't be empty! \n")}
  
  slide_input <- yaml::yaml.load_file(as.character(yaml_path))
  
  y <- as.matrix(utils::read.csv(slide_input$y_path, row.names = 1)) ## not standardized
  
  x <- as.matrix(utils::read.csv(slide_input$x_path, row.names = 1)) ## not standardized
  out_folder = paste0(slide_input$delta, '_', slide_input$lambda, '_out')
  out_folder = file.path(slide_input$out_path, out_folder)#, 'AllLatentFactors.rds')
  out_folder_ALF = file.path(out_folder, 'AllLatentFactors.rds')
  all_latent_factors <- readRDS(out_folder_ALF)
    #getLatentFactors(x=x,
                        #                 y=y,
                        #                 std_y = T,
                        #                 x_std = scale(x,T,T),
                         #                delta =slide_input$delta,
                         #                lambda = slide_input$lambda,
                          #               sigma = NULL)
  
  
  #z <- calcZMatrix(x_std = scale(x,T,T),all_latent_factors = all_latent_factors,out_path =".")
  
  #z <- scale(z,T,T)
  z_path = file.path(out_folder, 'z_matrix.csv')
  z = read.csv(z_path)
  f_size <- SLIDE::calcDefaultFsize(y=y,all_latent_factors = all_latent_factors)
  
  slide_input$std_cv <- T
  slide_input$std_y <- T
  slide_input$permute <- T
  slide_input$parallel <- T
  slide_input$fdr <- 0.1
  
  for(j in 1:nrep){
    
    withCallingHandlers(SLIDE::benchCV2(k =k,
             x = x,
             y = y,
             z=z,
             std_y = slide_input$std_y,
             std_cv = slide_input$std_cv,
             delta = slide_input$delta,
             permute = slide_input$permute,
             eval_type = slide_input$eval_type,
             y_levels = slide_input$y_levels,
             lambda = slide_input$lambda,
             out_path = slide_input$out_path,
             rep_cv = slide_input$rep_cv,
             alpha_level = slide_input$alpha_level,
             thresh_fdr = slide_input$thresh_fdr,
             rep = j,
             benchmark = F,
             niter=slide_input$SLIDE_iter,
             spec=slide_input$spec,
             fdr=slide_input$fdr,
             f_size=f_size,
             parallel = slide_input$parallel,
             ncore=20),
             error = function(e) {
               print(sys.calls())
             })
  }
  
  
  pathLists <- list.files(slide_input$out_path,recursive = T,pattern = "results")
  perfList <- lapply(paste0(slide_input$out_path,pathLists), readRDS)
  perRes <- do.call(rbind,lapply(perfList,function(x){x$final_corr}))
  
  
  if (slide_input$eval_type == "corr") {
    lambda_boxplot <- ggplot2::ggplot(data = perRes,
                                      ggplot2::aes(x = method,
                                                   y = corr,
                                                   fill = method)) +
      ggplot2::geom_boxplot() +
      ggplot2::labs(fill = "Method") +
      ggplot2::scale_alpha(guide = 'none')
  } else {
    lambda_boxplot <- ggplot2::ggplot(data = perRes,
                                      ggplot2::aes(x = method,
                                                   y = auc,
                                                   fill = method)) +
      ggplot2::geom_boxplot() +
      ggplot2::labs(fill = "Method") +
      ggplot2::scale_alpha(guide = 'none')
  }
  ggsave(paste0(slide_input$out_path,"/delta",slide_input$delta,"lambda",slide_input$lambda,"_boxplot.pdf"),lambda_boxplot)
  saveRDS(perRes,file=paste0(slide_input$out_path,"/delta",slide_input$delta,"lambda",slide_input$lambda,"_boxplot_data.rds"))
}

args <- commandArgs(trailingOnly = T)
yaml_path  <- args[1]
sprintf("The ymal path is:  %s",yaml_path)

SLIDEcv(yaml_path=yaml_path, nrep=20, k=10)
  
  