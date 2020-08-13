version 1.0

task downSamplingFile {
  input {
        File inputFile
        File referenceFile
        File referenceIndexFile
        String inputFileName
        Int disk_size
  }

  command {
    # Downsampling and Subsetting data by samtools
    if [ -f ${referenceFile} ]
    then
        # converting cram to bam
        samtools view -b ${inputFile} -T ${referenceFile} > ${inputFileName}.bam
        # downsampling and subsetting the file
        samtools view -bs 35.1 ${inputFileName}.bam > downsampled.${inputFileName}.bam
        # converting back to cram file
        samtools view -C downsampled.${inputFileName}.bam -T ${referenceFile} -o downsampled.${inputFileName}
    else
        #downsampling and subsetting the file
        samtools view -bs 35.1 ${inputFile} > downsampled.${inputFileName}
    fi
  }

  output {
    File downsampledFile = "downsampled.${inputFileName}"
  }

 runtime {
    docker: "quay.io/ibrahimjabarkhel/toolkit-for-generating-test-data:latest"
    cores: 4
    memory: "15 GB"
    disks: "local-disk " + disk_size + " HDD"
  }
  meta {
      author: "Ibrahim Jabarkhel"
      email: "ibrahimjabarkhil747@gmail.com"
      description: "This toolkit was developed with the goal of creating genomic test data by subsetting and downsampling BAM, CRAM, and SAM files. As a developer, we use test data often. It's sometimes better to use a section of whole data to test our model because small data is good for a quick test. Sometimes, there are very big datasets which will take more than a 24 hrs to run on their pipelines. Therefore, it is good to have a way to generate our own small test data. For more info: https://github.com/ibrahimjabarkhel/toolkit-for-generating-test-data"
  }
}


workflow toolkit_for_GTD {
  input {
        File referenceFile
        File inputFile
        File referenceIndexFile
        # Optional input to increase all disk sizes in case of outlier sample with strange size behavior
        # declare int variable that will help in increase disk size if needed
        Int? increase_disk_size
  }
  # Increase the disk size if the remaining disk size is less than 1 GB
  Int additional_diskSize = select_first([increase_disk_size, 20])
  
  # Get the size of the standard input file
  Float inputFileSize = size(inputFile, "GB")
  Int inputFileSize = ceil(size(inputFile, "GB"))
  Int ref_file_size = ceil(size(referenceFile, "GB") + size(referenceIndexFile, "GB"))
  Int output_size = ceil((inputFileSize/100)*15)
  String inputFileName = basename("${inputFile}")
  
  call downSamplingFile { input: inputFile = inputFile,
                 inputFileName = inputFileName,
                 referenceFile = referenceFile,
                 referenceIndexFile = referenceIndexFile,
                 disk_size = inputFileSize + additional_diskSize + ref_file_size + output_size
  }
}
