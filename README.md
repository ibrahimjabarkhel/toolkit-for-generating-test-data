# toolkit-for-generating-test-data
 
This toolkit was developed with the goal of creating genomic test data by subsetting and downsampling BAM, CRAM, and SAM files. As a developer, we use test data often. It's sometimes better to use a section of whole data to test our model because small data is good for a quick test. Sometimes, there are very big datasets which will take more than a 24 hrs to run on their pipelines. Therefore, it is good to have a way to generate our own small test data.

## Authors

Ibrahim Jabarkhel ibrahimjabarkhil747@gmail.com <br>
Nicholas Vasquez nivasquez@csumb.edu <br>
Ash O'Farrell aofarrel@ucsc.edu

## How to run toolkit-for-generating-test-data
If user doesn't want to build their own toolkit than go to section "Running Workflow with Dockstore CLI"

## Creating Own toolkit-for-generating-test-data

### Pre-requisities <br> 
Install docker in your local machine, follow this tutorial <a href="https://bioinformatics-core-shared-training.github.io/docker-4-bioinformatics/"> Docker-4-Bioinformatics </a>
After successful installation of Docker, download the Dockerfile from this repo or copy paste below code in any system editor and save it as Dockerfile (have no extensions).

    ##########################################################################
    # Dockerfile to build a downsampling tool container for Bam, SAM, and CRAM
    ##########################################################################

    # Set the base image to Ubuntu
    FROM ubuntu:14.04

    # File Author / Maintainer
    MAINTAINER Ibrahim Jabarkhel <ibrahimjabarkhil747@gmail.com>



    # Setup packages
    USER root
    RUN apt-get -m update 
    RUN apt-get install -y software-properties-common
    RUN add-apt-repository ppa:openjdk-r/ppa && apt-get update -q && apt-get install -y openjdk-11-jdk
    RUN apt-get install -y wget unzip zip
    RUN apt-get install -y wget build-essential



    RUN apt-get install -y ncurses-dev zlib1g-dev
    RUN wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2


    RUN mv samtools-1.3.1.tar.bz2 /opt
    WORKDIR /opt
    RUN tar -jxf samtools-1.3.1.tar.bz2
    WORKDIR samtools-1.3.1
    RUN ./configure
    RUN make
    RUN make install

    WORKDIR /opt/samtools-1.3.1

    # switch back to the ubuntu user so this tool (and the files written) are not owned by root
    RUN groupadd -r -g 1000 ubuntu && useradd -r -g ubuntu -u 1000 -m ubuntu
    USER ubuntu

    # by default /bin/bash is executed
    CMD ["/bin/bash"]

This Dockerfile is actually installing all dependencies for this toolkit and especially <b>samtools</b> through which we are subsetting and downsampling the files.

## Building in local machine manually
Execute this statement in local machine terminal

    $> docker build -t="toolkit-for-generating-test-data" .

After successfully creating the image than replace the docker image name in WDL file with your own image name. Download the Dockstore.wdl and test_input.json file from this repo.
Change image name in the wdl file at the runtime section:

    runtime {
      docker: "toolkit-for-generating-test-data:latest"
      memory: "15 GB"
      disks: "local-disk " + disk_size + " HDD"
    }
    
## Understanding of WDL and JSON File

First, this wdl file has task and workflow. The workflow is like a main function which will receiving inputs from the json file. It calls the task downSamplingFile which will downsample and subset the file and save the output in the local machine.

### Update the JSON File

    {
       "toolkit_for_GTD.inputFile": "gs://topmed_workflow_testing/topmed_aligner/input_files/NWD119836.0005.recab.cram",
       "toolkit_for_GTD.referenceFile": "gs://topmed_workflow_testing/topmed_variant_caller/reference_files/hg38/hs38DH.fa"
    }
    
provide the path to your SAM, BAM, or CRAM file location to toolkit_for_GTD.inputFile. If it's CRAM file than also provide path to reference file in toolkit_for_GTD.referenceFile.


## Running workflow with the Dockstore CLI

Download the Dockstore.wdl and test_input.json files. Open test_input.json file and provide the path to your BAM, SAM or CRAM file. If it's CRAM file than also provide a reference file. To run this workflow with our inputs in json file we need a dockstore CLI. <br>
Finally, run this workflow with the Dockstore CLI. If Dockstore is not installed yet, follow <a href="https://dockstore.org/quick-start"> this tutorial to install Dockstore CLI </a>. <br>
After successfully installing the Dockstore CLI, open Dockstore CLI or terminal or similar application in your system. Move to the directory where the WDL and JSON file exist. 

Run this statement to run the WDL workflow with the JSON file where inputs are given to generate a test data from it. <br>

    $> dockstore tool launch --local-entry dockstore.wdl --json test_input.json
    
    The below is a part of output after execution of above line
    # return exit code
	exit $rc
	[2020-08-02 16:04:37,56] [info] BackgroundConfigAsyncJobExecutionActor [[38;5;2me2419e1b[0mtoolkit_for_GTD.downSamplingFile:NA:1]: job id: 33717
	[2020-08-02 16:04:37,56] [info] BackgroundConfigAsyncJobExecutionActor [[38;5;2me2419e1b[0mtoolkit_for_GTD.downSamplingFile:NA:1]: Status change from - to WaitingForReturnCode
	[2020-08-02 16:07:22,86] [info] BackgroundConfigAsyncJobExecutionActor [[38;5;2me2419e1b[0mtoolkit_for_GTD.downSamplingFile:NA:1]: Status change from WaitingForReturnCode to Done
	[2020-08-02 16:07:23,76] [info] WorkflowExecutionActor-e2419e1b-1b1b-488d-be4d-ba2482e8a3f0 [[38;5;2me2419e1b[0m]: Workflow toolkit_for_GTD complete. Final Outputs:
	{
	  "toolkit_for_GTD.downSamplingFile.downsampledFile": "/private/var/folders/9b/5gh5_01n6mbfzf8k9zdxrtsw0000gn/T/1596409455707-0/cromwell-executions/toolkit_for_GTD/e2419e1b-1b1b-488d-be4d-ba2482e8a3f0/call-downSamplingFile/execution/downsampled.NWD119836.0005.recab.cram"
	}
	[2020-08-02 16:07:23,84] [info] WorkflowManagerActor WorkflowActor-e2419e1b-1b1b-488d-be4d-ba2482e8a3f0 is in a terminal state: WorkflowSucceededState
	[2020-08-02 16:07:42,14] [info] SingleWorkflowRunnerActor workflow finished with status 'Succeeded'.
	{
	  "outputs": {
	    "toolkit_for_GTD.downSamplingFile": "/private/var/folders/9b/5gh5_01n6mbfzf8k9zdxrtsw0000gn/T/1596409455707-0/cromwell-executions/toolkit_for_GTD/e2419e1b-1b1b-488d-be4d-ba2482e8a3f0/call-downSamplingFile/execution/downsampled.NWD119836.0005.recab.cram"
	  }


So that’s a lot of information but you can see the process was a success. The output is kind of hard to parse, but look for the following text

    workflow finished with status 'Succeeded'.
     {
       "outputs": {
         "toolkit_for_GTD.downSamplingFile": "/private/var/folders/9b/5gh5_01n6mbfzf8k9zdxrtsw0000gn/T/1596409455707-0/cromwell-executions/toolkit_for_GTD/e2419e1b-1b1b-488d-be4d-ba2482e8a3f0/call-downSamplingFile/execution/downsampled.NWD119836.0005.recab.cram"
       }
     }

The final output can be found at

- /private/var/folders/9b/5gh5_01n6mbfzf8k9zdxrtsw0000gn/T/1596409455707-0/cromwell-executions/toolkit_for_GTD/e2419e1b-1b1b-488d-be4d-ba2482e8a3f0/call-downSamplingFile/execution/downsampled.NWD119836.0005.recab.cram

Please note that when you are running this WDL on your local machine, the final output will be in a different folder. What's shown here is an example. However, by default, if you are running on the Dockstore CLI on a Mac OS X machine, the output will be somewhere in /private/var/
