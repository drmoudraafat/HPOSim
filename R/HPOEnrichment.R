getGeneDefaultBackground<-function(){
  initialize()  
  gene2hpo<-get("gene2hpo",envir=HPOSimEnv) 
  return(names(gene2hpo)) 
}
getDiseaseDefaultBackground<-function(){
  initialize()  
  disease2hpo<-get("disease2hpo",envir=HPOSimEnv) 
  return(names(disease2hpo)) 
}

HPOGeneEnrichment <-
  function(genelist,filter=5,cutoff=0.05,background=getGeneDefaultBackground()){
    initialize()  
    if(is.list(genelist)){
      genelist<-unique(unlist(genelist));
    }else{
      genelist<-unique(genelist); 
    }	
    
    genelist<-as.character(genelist)

    #get gene annotated HPOterms
    gene2hpo<-get("gene2hpo",envir=HPOSimEnv)
    annotatedhpoids<-gene2hpo[genelist[genelist %in% names(gene2hpo)]] 
    annotatedhpoids<-unique(unlist(annotatedhpoids)) 
    if(length(annotatedhpoids) == 0){ 
      stop(paste("No HPOIDS are annotated by",length(genelist),"gene list"))
    }
    
    hpo2gene<-get("hpo2gene",envir=HPOSimEnv) 

    #filter out hpoid which have at least 5 geneids annotated to this term
    filteredhpoids<-sapply(annotatedhpoids,function(x){length(hpo2gene[[x]])>=filter})
    filteredhpoids<-annotatedhpoids[filteredhpoids] 
    
    if(length(filteredhpoids)==0){ 
      stop(paste("No HPOIDS annotated by",length(genelist),"gene list match the requirement that have at least",filter,"genes annotated to the HPO term."))
    }
    
    #######################################
    
    humangenenum<-length(background) 
    res<-list()
    searchgenenum<-length(genelist) 
    for(i in 1:length(filteredhpoids)){
      n<-length(hpo2gene[[filteredhpoids[i]]]) 
      m<-length(genelist[genelist %in% hpo2gene[[filteredhpoids[i]]]]) 
      #p=phyper(m,n,humangenenum-n,searchgenenum,lower.tail=FALSE)
      p=1-phyper(m-1,n,humangenenum-n,searchgenenum) 
      res[[filteredhpoids[i]]]<-list('hpoid'=filteredhpoids[i],'pvalue'=p,'odds'=(m/searchgenenum)/(n/humangenenum),'annGeneNumber'=m,'annBgNumber'=searchgenenum,'geneNumber'=n,'bgNumber'=humangenenum) 
    }
    
    if(length(res)==0){
      res=NULL;
      return(res)
    }else{
      res<-data.frame("HPOID"=sapply(res,function(x){x$hpoid}),"annGeneNumber"=sapply(res,function(x){x$annGeneNumber}),"annBgNumber"=sapply(res,function(x){x$annBgNumber}),"geneNumber"=sapply(res,function(x){x$geneNumber}),"bgNumber"=sapply(res,function(x){x$bgNumber}),"odds"=sapply(res,function(x){x$odds}),"pvalue"=sapply(res,function(x){x$pvalue}))
    }
    
    qvalueList=p.adjust(res$pvalue,method="fdr") 
    res<-data.frame(res,"qvalue"=qvalueList) 
    sort.data.frame <- function(x, key, ...) { 
      if (missing(key)) {
        rn <- rownames(x)
        if (all(rn %in% 1:nrow(x))) rn <- as.numeric(rn)
        x[order(rn, ...), , drop=FALSE]
      } else {
        x[do.call("order", c(x[key], ...)), , drop=FALSE]
      }
    }
    
    res<-sort.data.frame(res,"qvalue",decreasing=FALSE) 
    res<-res[res$qvalue<=cutoff,]	
  }


HPODiseaseEnrichment <-
  function(diseaselist,filter=5,cutoff=0.05,background=getDiseaseDefaultBackground()){
    if(is.list(diseaselist)){
      diseaselist<-unique(unlist(diseaselist));
    }else{
      diseaselist<-unique(diseaselist); 
    }
    
    diseaselist<-as.character(diseaselist)
    ######################################
    initialize()
    disease2hpo<-get("disease2hpo",envir=HPOSimEnv)
    annotatedhpoids<-disease2hpo[diseaselist[diseaselist %in% names(disease2hpo)]] 
    annotatedhpoids<-unique(unlist(annotatedhpoids)) 
    if(length(annotatedhpoids) == 0){ 
      stop(paste("No HPOIDS are annotated by",length(diseaselist),"disease list"))
    }
    hpo2disease<-get("hpo2disease",envir=HPOSimEnv)

    ######################################
    #filter out hpoid which have at least 5 diseaseids annotated to this term
    
    filteredhpoids<-sapply(annotatedhpoids,function(x){length(hpo2disease[[x]])>=filter}) 
    filteredhpoids<-annotatedhpoids[filteredhpoids] 
    
    if(length(filteredhpoids)==0){ 
      stop(paste("No HPOIDS annotated by",length(diseaselist),"disease list match the requirement that have at least",filter,"diseases annotated to the HPO term."))
    }
    
    #######################################
    
    humandiseasenum<-length(background) 
    res<-list()
    searchdiseasenum<-length(diseaselist) 
    for(i in 1:length(filteredhpoids)){
      n<-length(hpo2disease[[filteredhpoids[i]]]) 
      m<-length(diseaselist[diseaselist %in% hpo2disease[[filteredhpoids[i]]]]) 
      #p=phyper(m,n,humandiseasenum-n,searchdiseasenum,lower.tail=FALSE)
      p=1-phyper(m-1,n,humandiseasenum-n,searchdiseasenum) 
      res[[filteredhpoids[i]]]<-list('hpoid'=filteredhpoids[i],'pvalue'=p,'odds'=(m/searchdiseasenum)/(n/humandiseasenum),'annDiseaseNumber'=m,'annBgNumber'=searchdiseasenum,'diseaseNumber'=n,'bgNumber'=humandiseasenum) #��ÿ��HPOID����һ���б���������sapplyѭ���������ݿ�
    }
    
    if(length(res)==0){
      res=NULL;
      return(res)
    }else{
      res<-data.frame("HPOID"=sapply(res,function(x){x$hpoid}),"annDiseaseNumber"=sapply(res,function(x){x$annDiseaseNumber}),"annBgNumber"=sapply(res,function(x){x$annBgNumber}),"diseaseNumber"=sapply(res,function(x){x$diseaseNumber}),"bgNumber"=sapply(res,function(x){x$bgNumber}),"odds"=sapply(res,function(x){x$odds}),"pvalue"=sapply(res,function(x){x$pvalue}))
    }
    
    qvalueList=p.adjust(res$pvalue,method="fdr") 

    res<-data.frame(res,"qvalue"=qvalueList) 
    sort.data.frame <- function(x, key, ...) { 
      if (missing(key)) {
        rn <- rownames(x)
        if (all(rn %in% 1:nrow(x))) rn <- as.numeric(rn)
        x[order(rn, ...), , drop=FALSE]
      } else {
        x[do.call("order", c(x[key], ...)), , drop=FALSE]
      }
    }
    
    res<-sort.data.frame(res,"qvalue",decreasing=FALSE) 
    res<-res[res$qvalue<=cutoff,] 
    print(res) #result
  }

HPOGeneNOAWholeNetEnrichment <-
  function(file,filter=5,cutoff=0.05){
    initialize()  
    network<-read.csv(file,header=F)
    nodelist<-list() 
    for(i in 2:nrow(network))
    {
      line<-network[i,]
      line<-line[line!=""] 
      for(j in 1:2)
        nodelist[length(nodelist)+1]<-line[j]
    }
    nodelist<-unique(unlist(nodelist))
    if(length(nodelist)<2){ 
      stop(paste("Nodes not enough."))
    }
    ######################################
    
    gene2hpo<-get("gene2hpo",envir=HPOSimEnv)
    edge<-matrix(nrow=length(nodelist),ncol=length(nodelist)) 
    rownames(edge)<-nodelist
    colnames(edge)<-nodelist
    edgenum<-0 
    annotatedhpoids<-list() 
    hpo2edge<-list() 
    bound1<-length(nodelist)-1
    for(i in 1:bound1)
    {
      bound2<-i+1 
      for(j in bound2:length(nodelist))
      {
        hpo1<-gene2hpo[[nodelist[i]]]
        hpo2<-gene2hpo[[nodelist[j]]]
        interset<-hpo1[hpo1 %in% hpo2] 
        if(length(interset)>=1) 
        {
          edge[nodelist[i],nodelist[j]]<-edgenum 
          edge[nodelist[j],nodelist[i]]<-edgenum
          for(k in 1:length(interset))
          {
            annotatedhpoids[length(annotatedhpoids)+1]<-interset[k] 
            hpo2edge[[interset[k]]][length(hpo2edge[[interset[k]]])+1]<-edgenum 
          }
          edgenum<-edgenum+1
        }
      }
    }
    annotatedhpoids<-unique(unlist(annotatedhpoids))
    if(length(annotatedhpoids) == 0){ 
      stop(paste("No HPOIDS are annotated by the input graph"))
    }
    ######################################
    
    #get the list of the edges inputed by users
    edgelist<-list() 
    for(i in 2:nrow(network))
    {
      line<-network[i,]
      line<-line[line!=""] 
      edgelist[length(edgelist)+1]<-edge[line[1],line[2]]
    }
    edgelist<-unique(na.omit(unlist(edgelist)))
    ######################################
    
    #filter out hpoid which have at least [filter] edges annotated to this term
    filteredhpoids<-sapply(annotatedhpoids,function(x){length(hpo2edge[[x]])>=filter}) 
    filteredhpoids<-annotatedhpoids[filteredhpoids] 
    
    if(length(filteredhpoids)==0){ 
      stop(paste("No HPOID has more than",filter,"edges annotated."))
    }
    
    #######################################
    res<-list()
    edgenum<-length(nodelist)*(length(nodelist)-1)/2 
    searchedgenum<-length(edgelist) #number of edges to be analyzed
    for(i in 1:length(filteredhpoids)){
      n<-length(hpo2edge[[filteredhpoids[i]]]) #number of edges annotated to the HPO term
      m<-length(edgelist[edgelist %in% hpo2edge[[filteredhpoids[i]]]]) #number of edges in the edgelist annotated to the HPO term
      #p=phyper(m,n,humangenenum-n,searchgenenum,lower.tail=FALSE)
      p=1-phyper(m-1,n,edgenum-n,searchedgenum) 
      
      res[[filteredhpoids[i]]]<-list('hpoid'=filteredhpoids[i],'pvalue'=p,'odds'=(m/searchedgenum)/(n/edgenum),'annEdgeNumber'=m,'annBgNumber'=searchedgenum,'edgeNumber'=n,'bgNumber'=edgenum) 
    }
    
    if(length(res)==0){
      res=NULL;
      return(res)
    }else{
      res<-data.frame("HPOID"=sapply(res,function(x){x$hpoid}),"annEdgeNumber"=sapply(res,function(x){x$annEdgeNumber}),"annBgNumber"=sapply(res,function(x){x$annBgNumber}),"edgeNumber"=sapply(res,function(x){x$edgeNumber}),"bgNumber"=sapply(res,function(x){x$bgNumber}),"odds"=sapply(res,function(x){x$odds}),"pvalue"=sapply(res,function(x){x$pvalue}))
    }
    
    qvalueList=p.adjust(res$pvalue,method="fdr") 
    res<-data.frame(res,"qvalue"=qvalueList) 
    sort.data.frame <- function(x, key, ...) {
      if (missing(key)) {
        rn <- rownames(x)
        if (all(rn %in% 1:nrow(x))) rn <- as.numeric(rn)
        x[order(rn, ...), , drop=FALSE]
      } else {
        x[do.call("order", c(x[key], ...)), , drop=FALSE]
      }
    }
    
    res<-sort.data.frame(res,"qvalue",decreasing=FALSE) 
    res<-res[res$qvalue<=cutoff,]  
    print(res)  
  }

HPODiseaseNOAWholeNetEnrichment <-
  function(file,filter=5,cutoff=0.05){
    initialize()  
    network<-read.csv(file,header=F)
    #get all the nodes in the graph
    nodelist<-list() #�ڵ��б�
    for(i in 2:nrow(network))
    {
      line<-network[i,]
      line<-line[line!=""] #ȡ�ڵ���
      for(j in 1:2)
        nodelist[length(nodelist)+1]<-line[j]
    }
    nodelist<-unique(unlist(nodelist))
    if(length(nodelist)<2){ 
      stop(paste("Nodes not enough."))
    }
    ######################################
    
    #give each edges in the complete graph a label
    disease2hpo<-get("disease2hpo",envir=HPOSimEnv)
    edge<-matrix(nrow=length(nodelist),ncol=length(nodelist)) 
    rownames(edge)<-nodelist
    colnames(edge)<-nodelist
    edgenum<-0 
    annotatedhpoids<-list() 
    hpo2edge<-list() 
    bound1<-length(nodelist)-1 
    for(i in 1:bound1)
    {
      bound2<-i+1 
      for(j in bound2:length(nodelist))
      {
        hpo1<-disease2hpo[[nodelist[i]]]
        #print(paste("disease1:",nodelist[i]," HPO id:",hpo1))
        hpo2<-disease2hpo[[nodelist[j]]]
        #print(paste("disease2:",nodelist[j]," HPO id:",hpo2))
            
        interset<-hpo1[hpo1 %in% hpo2] 
        if(length(interset)>=1) 
        {
          edge[nodelist[i],nodelist[j]]<-edgenum 
          edge[nodelist[j],nodelist[i]]<-edgenum
          for(k in 1:length(interset))
          {
            annotatedhpoids[length(annotatedhpoids)+1]<-interset[k] 
            hpo2edge[[interset[k]]][length(hpo2edge[[interset[k]]])+1]<-edgenum 
          }
          edgenum<-edgenum+1
        }
      }
    }
    annotatedhpoids<-unique(unlist(annotatedhpoids))
    if(length(annotatedhpoids) == 0){ 
      stop(paste("No HPOIDS are annotated by the input graph"))
    }
    ######################################
    
    edgelist<-list() 
    for(i in 2:nrow(network))
    {
      line<-network[i,]
      line<-line[line!=""] 
      edgelist[length(edgelist)+1]<-edge[line[1],line[2]]
    }
    edgelist<-unique(na.omit(unlist(edgelist)))
    ######################################
    
    #filter out hpoid which have at least 5 edges annotated to this term
    filteredhpoids<-sapply(annotatedhpoids,function(x){length(hpo2edge[[x]])>=filter}) 
    filteredhpoids<-annotatedhpoids[filteredhpoids] 
    
    if(length(filteredhpoids)==0){ 
      stop(paste("No HPOID has more than",filter,"edges annotated."))
    }
    
    #######################################
    res<-list()
    edgenum<-length(nodelist)*(length(nodelist)-1)/2 
    searchedgenum<-length(edgelist) 
    for(i in 1:length(filteredhpoids)){
      n<-length(hpo2edge[[filteredhpoids[i]]]) 
      m<-length(edgelist[edgelist %in% hpo2edge[[filteredhpoids[i]]]]) 
      #p=phyper(m,n,humangenenum-n,searchgenenum,lower.tail=FALSE)
      p=1-phyper(m-1,n,edgenum-n,searchedgenum) 
      
      res[[filteredhpoids[i]]]<-list('hpoid'=filteredhpoids[i],'pvalue'=p,'odds'=(m/searchedgenum)/(n/edgenum),'annEdgeNumber'=m,'annBgNumber'=searchedgenum,'edgeNumber'=n,'bgNumber'=edgenum) 
    }
    
    if(length(res)==0){
      res=NULL;
      return(res)
    }else{
      res<-data.frame("HPOID"=sapply(res,function(x){x$hpoid}),"annEdgeNumber"=sapply(res,function(x){x$annEdgeNumber}),"annBgNumber"=sapply(res,function(x){x$annBgNumber}),"edgeNumber"=sapply(res,function(x){x$edgeNumber}),"bgNumber"=sapply(res,function(x){x$bgNumber}),"odds"=sapply(res,function(x){x$odds}),"pvalue"=sapply(res,function(x){x$pvalue}))
    }
    
    qvalueList=p.adjust(res$pvalue,method="fdr") 
    res<-data.frame(res,"qvalue"=qvalueList) 
    sort.data.frame <- function(x, key, ...) { 
      if (missing(key)) {
        rn <- rownames(x)
        if (all(rn %in% 1:nrow(x))) rn <- as.numeric(rn)
        x[order(rn, ...), , drop=FALSE]
      } else {
        x[do.call("order", c(x[key], ...)), , drop=FALSE]
      }
    }
    
    res<-sort.data.frame(res,"qvalue",decreasing=FALSE) 
    res<-res[res$qvalue<=cutoff,]  
    print(res)  
  }



HPOGeneNOASubNetEnrichment <-
  function(testfile,backgroundfile,filter=5,cutoff=0.05){
    initialize()  
    testnetwork<-read.csv(testfile,header=F) 
    backgroundnetwork<-read.csv(backgroundfile,header=F) #reference set
    #get all the nodes in reference set
    nodelist<-list() 
    for(i in 2:nrow(backgroundnetwork))
    {
      line<-backgroundnetwork[i,]
      line<-line[line!=""] 
      for(j in 1:2)
        nodelist[length(nodelist)+1]<-line[j]
    }
    nodelist<-unique(unlist(nodelist))
    if(length(nodelist)<2){ 
      stop(paste("Nodes not enough."))
    }
    ######################################
    
    gene2hpo<-get("gene2hpo",envir=HPOSimEnv)
    edge<-matrix(nrow=length(nodelist),ncol=length(nodelist)) 
    rownames(edge)<-nodelist
    colnames(edge)<-nodelist
    edgenum<-0 
    annotatedhpoids<-list() 
    hpo2edge<-list() 
    for(i in 2:nrow(backgroundnetwork))
    {
      line<-backgroundnetwork[i,]
      line<-line[line!=""] 
      hpo1<-gene2hpo[[line[1]]]
      hpo2<-gene2hpo[[line[2]]]
      interset<-hpo1[hpo1 %in% hpo2] 
      if(length(interset)>=1) 
      {
        edge[line[1],line[2]]<-edgenum 
        edge[line[2],line[1]]<-edgenum
        for(k in 1:length(interset))
        {
          annotatedhpoids[length(annotatedhpoids)+1]<-interset[k] 
          hpo2edge[[interset[k]]][length(hpo2edge[[interset[k]]])+1]<-edgenum #
        }
        edgenum<-edgenum+1
      }
    }
    annotatedhpoids<-unique(unlist(annotatedhpoids))
    if(length(annotatedhpoids) == 0){ 
      stop(paste("No HPOIDS are annotated by the input graph"))
    }
    ######################################
    
    edgelist<-list() #���б�
    for(i in 2:nrow(testnetwork))
    {
      line<-testnetwork[i,]
      line<-line[line!=""] 
      if(!(line[1] %in% nodelist) || !(line[2] %in% nodelist)) 
        stop(paste("Test network is not included in background network."))
      edgelist[length(edgelist)+1]<-edge[line[1],line[2]]
    }
    edgelist<-unique(na.omit(unlist(edgelist)))
    ######################################
    
    #filter out hpoid which have at least [filter] edges annotated to this term
    filteredhpoids<-sapply(annotatedhpoids,function(x){length(hpo2edge[[x]])>=filter}) 
    filteredhpoids<-annotatedhpoids[filteredhpoids] 
    
    if(length(filteredhpoids)==0){ 
      stop(paste("No HPOID has more than",filter,"edges annotated."))
    }
    
    #######################################
    res<-list()
    edgenum<-nrow(backgroundnetwork)-1 
    searchedgenum<-length(edgelist) 
    for(i in 1:length(filteredhpoids)){
      n<-length(hpo2edge[[filteredhpoids[i]]]) 
      m<-length(edgelist[edgelist %in% hpo2edge[[filteredhpoids[i]]]]) 
      #p=phyper(m,n,humangenenum-n,searchgenenum,lower.tail=FALSE)
      p=1-phyper(m-1,n,edgenum-n,searchedgenum) 
      
      res[[filteredhpoids[i]]]<-list('hpoid'=filteredhpoids[i],'pvalue'=p,'odds'=(m/searchedgenum)/(n/edgenum),'annEdgeNumber'=m,'annBgNumber'=searchedgenum,'edgeNumber'=n,'bgNumber'=edgenum) 
    }
    
    if(length(res)==0){
      res=NULL;
      return(res)
    }else{
      res<-data.frame("HPOID"=sapply(res,function(x){x$hpoid}),"annEdgeNumber"=sapply(res,function(x){x$annEdgeNumber}),"annBgNumber"=sapply(res,function(x){x$annBgNumber}),"edgeNumber"=sapply(res,function(x){x$edgeNumber}),"bgNumber"=sapply(res,function(x){x$bgNumber}),"odds"=sapply(res,function(x){x$odds}),"pvalue"=sapply(res,function(x){x$pvalue}))
    }
   
    qvalueList=p.adjust(res$pvalue,method="fdr") 
    res<-data.frame(res,"qvalue"=qvalueList) 
    sort.data.frame <- function(x, key, ...) { 
      if (missing(key)) {
        rn <- rownames(x)
        if (all(rn %in% 1:nrow(x))) rn <- as.numeric(rn)
        x[order(rn, ...), , drop=FALSE]
      } else {
        x[do.call("order", c(x[key], ...)), , drop=FALSE]
      }
    }
    
    res<-sort.data.frame(res,"qvalue",decreasing=FALSE) 
    res<-res[res$qvalue<=cutoff,]  
    print(res)  
  }



HPODiseaseNOASubNetEnrichment <-
  function(testfile,backgroundfile,filter=5,cutoff=0.05){
    initialize()  
    testnetwork<-read.csv(testfile,header=F) 
    backgroundnetwork<-read.csv(backgroundfile,header=F) 
    
    nodelist<-list() 
    for(i in 2:nrow(backgroundnetwork))
    {
      line<-backgroundnetwork[i,]
      line<-line[line!=""] 
      for(j in 1:2)
        nodelist[length(nodelist)+1]<-line[j]
    }
    nodelist<-unique(unlist(nodelist))
    if(length(nodelist)<2){ 
      stop(paste("Nodes not enough."))
    }
    ######################################
    
    disease2hpo<-get("disease2hpo",envir=HPOSimEnv)
    edge<-matrix(nrow=length(nodelist),ncol=length(nodelist)) 
    rownames(edge)<-nodelist
    colnames(edge)<-nodelist
    edgenum<-0 
    annotatedhpoids<-list() 
    hpo2edge<-list() 
    for(i in 2:nrow(backgroundnetwork))
    {
      line<-backgroundnetwork[i,]
      line<-line[line!=""] 
      hpo1<-disease2hpo[[line[1]]]
      hpo2<-disease2hpo[[line[2]]]
      interset<-hpo1[hpo1 %in% hpo2] 
      if(length(interset)>=1) 
      {
        edge[line[1],line[2]]<-edgenum 
        edge[line[2],line[1]]<-edgenum
        for(k in 1:length(interset))
        {
          annotatedhpoids[length(annotatedhpoids)+1]<-interset[k] 
          hpo2edge[[interset[k]]][length(hpo2edge[[interset[k]]])+1]<-edgenum 
        }
        edgenum<-edgenum+1
      }
    }
    annotatedhpoids<-unique(unlist(annotatedhpoids))
    if(length(annotatedhpoids) == 0){ 
      stop(paste("No HPOIDS are annotated by the input graph"))
    }
    ######################################
    
    edgelist<-list() 
    for(i in 2:nrow(testnetwork))
    {
      line<-testnetwork[i,]
      line<-line[line!=""] 
      if(!(line[1] %in% nodelist) || !(line[2] %in% nodelist)) 
        stop(paste("Test network is not included in background network."))
      edgelist[length(edgelist)+1]<-edge[line[1],line[2]]
    }
    edgelist<-unique(na.omit(unlist(edgelist)))
    ######################################
    
    #filter out hpoid which have at least [filter] edges annotated to this term
    filteredhpoids<-sapply(annotatedhpoids,function(x){length(hpo2edge[[x]])>=filter}) 
    filteredhpoids<-annotatedhpoids[filteredhpoids] 
    
    if(length(filteredhpoids)==0){ 
      stop(paste("No HPOID has more than",filter,"edges annotated."))
    }
    
    #######################################
    res<-list()
    edgenum<-nrow(backgroundnetwork)-1 
    searchedgenum<-length(edgelist) 
    for(i in 1:length(filteredhpoids)){
      n<-length(hpo2edge[[filteredhpoids[i]]]) 
      m<-length(edgelist[edgelist %in% hpo2edge[[filteredhpoids[i]]]]) 
      #p=phyper(m,n,humangenenum-n,searchgenenum,lower.tail=FALSE)
      p=1-phyper(m-1,n,edgenum-n,searchedgenum)
      
      res[[filteredhpoids[i]]]<-list('hpoid'=filteredhpoids[i],'pvalue'=p,'odds'=(m/searchedgenum)/(n/edgenum),'annEdgeNumber'=m,'annBgNumber'=searchedgenum,'edgeNumber'=n,'bgNumber'=edgenum) 
    }
    
    if(length(res)==0){
      res=NULL;
      return(res)
    }else{
      res<-data.frame("HPOID"=sapply(res,function(x){x$hpoid}),"annEdgeNumber"=sapply(res,function(x){x$annEdgeNumber}),"annBgNumber"=sapply(res,function(x){x$annBgNumber}),"edgeNumber"=sapply(res,function(x){x$edgeNumber}),"bgNumber"=sapply(res,function(x){x$bgNumber}),"odds"=sapply(res,function(x){x$odds}),"pvalue"=sapply(res,function(x){x$pvalue}))
    }
    
    qvalueList=p.adjust(res$pvalue,method="fdr") 
    res<-data.frame(res,"qvalue"=qvalueList) 
    sort.data.frame <- function(x, key, ...) { 
      if (missing(key)) {
        rn <- rownames(x)
        if (all(rn %in% 1:nrow(x))) rn <- as.numeric(rn)
        x[order(rn, ...), , drop=FALSE]
      } else {
        x[do.call("order", c(x[key], ...)), , drop=FALSE]
      }
    }
    
    res<-sort.data.frame(res,"qvalue",decreasing=FALSE) 
    res<-res[res$qvalue<=cutoff,]  
    print(res)  
  }