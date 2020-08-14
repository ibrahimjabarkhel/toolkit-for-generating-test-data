version 1.0

task downSamplingFile {
  input {
        File inputFile
        File referenceFile
        File referenceIndexFile
        String inputFileName
        Float disk_size
        File? bamFile
        File? downSBamFile
        File? downSCramFile
  }
  

  command {
    # Downsampling and Subsetting data by samtools
    if [ -f ${referenceFile} ]
    then
        # converting cram to bam
        samtools view -b ${inputFile} -T ${referenceFile} > bamFile
        # downsampling and subsetting the file
        samtools view -bs $((20 + RANDOM % 46)).1 ${bamFile} > downSBamFile
        # converting back to cram file
        samtools view -C ${downSBamFile} -T ${referenceFile} -o downSCramFile
    else
        #downsampling and subsetting the file
        samtools view -bs $((20 + RANDOM % 46)).1 ${inputFile} > downSCramFile
    fi
  }

  Float bamSize = size(bamFile, "GB")
  Float downSBamSize = size(downSBamFile, "GB")
  Float downSCramSize = size(downSCramFile, "GB")
  Float final_disk_size = disk_size + bamSize + downSBamSize + downSCramSize

  String s = final_disk_size
  String string_before_decimal = sub(s, "\\..*", "")
  Int new_disk_size = string_before_decimal

  output {
    File downsampledFile = "downSCramFile"
  }

  runtime {
    docker: "quay.io/ibrahimjabarkhel/toolkit-for-generating-test-data:latest"
    memory: "15 GB"
    disks: "local-disk " + new_disk_size + " HDD"
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
        File? bamFile
        File? downSBamFile
        File? downSCramFile
  }

  # Increase the disk size if the remaining disk size is less than 1 GB
  Int additional_diskSize = select_first([increase_disk_size, 20])
  
  # Get the size of the standard input file
  Float inputFileSize = size(inputFile, "GB")
  Float ref_file_size = size(referenceFile, "GB") + size(referenceIndexFile, "GB")
  Float output_size = (inputFileSize/100)*15
  String inputFileName = basename("${inputFile}")

  call downSamplingFile { input: inputFile = inputFile,
                 inputFileName = inputFileName,
                 referenceFile = referenceFile,
                 referenceIndexFile = referenceIndexFile,
                 bamFile = bamFile,
                 downSBamFile = downSBamFile, downSCramFile = downSCramFile,
                 disk_size = inputFileSize + additional_diskSize + ref_file_size + output_size
  }
}
