This pipeline tries to automate a basic RNA-Seq pipeline.

The pipelinetries to be replicable and to have minimum dependencies.

In order to run the pipeline you need

git: to clone the repository
wget & curl: to download files
make:  for automating the basic comands
snakemake: The workflow is implemented in snakemake so needs to be installed with all it's dependencies.(Folow the online instructions using a conda virtual environment)
*** In next version snakemake would be dockerized so no need to install in your local.
docker:  All the tools are dockerized to avoid installing and versioning issues.


The project is tested in ubuntu and more ore less assumed Linux & MacOs compatability.


To run

1. clone the project to your local machine
2. go to the root folder of the project where Makefile file is (all make commands should be executed from here)
3. from bash (in project root folder where Makefile is) run  **make create-pipeline-folder-structure** to create the folder structure in ./data directory
4. from bash (in project root folder where Makefile is) run  **make download-samples-raw** to download the 12  sequenced files
5. from bash (in project root folder where Makefile is) run  **make download-ref-gen-files** to download the mus ref gene files
6. from bash (in project root folder where Makefile is) run  **make build-images-all** to build all the docker images with the tools
7. from bash (in project root folder where Makefile is) run  **make duild-hisat2-ref-gene-index** to build the index for hisat2 (takes some time)
8. Hip Hip Hooray  Ready to run your pipeline
9. from bash (in project root folder where Makefile is) run  **make run-pipeline-e2e-np** to dry-run the pipeline or **make make run-pipeline-e2e** to run pipeline


To run the pipeline no need to go through the make file commands  you can use snakemake invocations commands something like **snakemake -s pipelines/RNASeqBasic01  --cores 4  -R geneCount_all **
