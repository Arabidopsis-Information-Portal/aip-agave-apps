# This is a generic wrapper script for running docker containers. 
# All docker apps take one optional common parameter, `dockerImage`. This is the 
# name of the container image that will be run. Additionally, any
# other app-specific parameters may be specified. Notice that all we are
# doing here is setting up local variables to receive the values passed 
# in from the job

DOCKER_IMAGE="ncbi-blast"

# In addition to the common parameter, all docker apps take a single 
# common input file, `dockerFile`, which is also optional. Either the 
# dockerImage or the dockerFile should be specified in order to properly
# run the container. In this example, we only use the dockerImage

#DOCKER_FILE=${dockerFile}

# Craft your Docker env here, adding volumes, constraints, etc
# before getting into your app-specific logic
DOCKER_COMMAND="docker run -i -t -v /home/vaughn/storage/databases/blast:/databases:ro -v `pwd`:/scratch:rw -w /scratch -e BLASTDB=/databases"

# In the follow section, you would enter application specific input files.
# As with native apps, the input files will be present in the job directory
# when this script is run.

FILENAME="${query}"

# Check for existence of input file.
if [ -e $FILENAME ]; then
	
	# Build up the arguments string
	# Start with common arguments that are mandatory or created via showArgument
	DBS="${database}"
	ARGS="${evalue} ${ungapped} ${max_target_seqs} ${filter} ${lowercase_masking} ${wordsize} ${gapopen} ${gapextend} ${matrix} -num_threads 2"
	
	# Not used by TBLASTN so we don't insert them above
	# gencode reward penalty

# Add arguments programmatically	
# Unify -html and -outfmt format modes
case ${format} in
	HTML)
		ARGS="$ARGS -html"
		;;
	TEXT)
		ARGS="$ARGS -outfmt 0"
		;;
	XML)
		ARGS="$ARGS -outfmt 5"
		;;
	TABULAR)
		ARGS="$ARGS -outfmt 6"
		;;
	TABULAR_COMMENTED)
		ARGS="$ARGS -outfmt 7"
		;;
	ASN1)
		ARGS="$ARGS -outfmt 11"
		;;
esac		

	# Run in Docker as follows
	# Mount pwd as /scratch then use scratch as working directory
	# Use base image DOCKER_IMAGE
	# Use bash as the parent shell rather than sh
	# ^ Might be able to set this using entrypoint instead
	${DOCKER_COMMAND} ${DOCKER_IMAGE} tblastn -db "${DBS}" ${ARGS} -query $FILENAME -out tblastn_out

	# Good practice would suggest that you clean up your image after running. For throughput
	# you may want to leave it in place. iPlant's docker servers will clean up after themselves
	# using a purge policy based on size, demand, and utilization.

	#sudo docker rmi $DOCKER_IMAGE
fi

