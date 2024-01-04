
#!/bin/bash
MAX_BACKUP_FILES=24  #change to 24
BACKUP_MAIN_DIR="/home/majid/container_backups"
CONTAINER_BACKUP_DIR="backup"

# Check if backup main directory exists, create if not
if [ ! -d $BACKUP_MAIN_DIR ]; then       #/home/majid/containerbackup  directory exist or not
        mkdir -p $BACKUP_MAIN_DIR
        echo "MAIN BACKUP DIRECTORY CREATED SUCCESFULLY"
fi

for (( i=1 ; i<=$(docker ps -aq | wc -l) ; i++ ));
    do
        CONTAINER_NAME=$(docker ps --format "table {{.Names}}" -a | awk 'NR=='$i+1'')
        echo $CONTAINER_NAME

    if [ ! -f $BACKUP_MAIN_DIR/$CONTAINER_BACKUP_DIR-${CONTAINER_NAME}-* ]; then
        NUM_BACKUP_FOR_SPECEFIC_CONTAINER=0;
        echo "WE are creating first backup from  $CONTAINER_NAME container"
        BACKUP_FILE_NUMBER="$(( $NUM_BACKUP_FOR_SPECEFIC_CONTAINER+1 ))"
    else
        BACKUP_FILE=("$BACKUP_MAIN_DIR/$CONTAINER_BACKUP_DIR-${CONTAINER_NAME}"*)  # the star(*) end of directory shows all file in that specific directory
        NUM_BACKUP_FOR_SPECEFIC_CONTAINER="${#BACKUP_FILE[@]}"  #  count of  backup_fie from one specific container
        echo "WE were created befor $NUM_BACKUP_FOR_SPECEFIC_CONTAINER  backup from  $CONTAINER_NAME container"
    BACKUP_FILE_NUMBER="$(( $NUM_BACKUP_FOR_SPECEFIC_CONTAINER+1 ))" #backup file number and we tag to your backup to know how many backup from specific continer created
    
    fi
    
        if [ $BACKUP_FILE_NUMBER -gt $MAX_BACKUP_FILE ]; then
        # Remove the oldest backup file include image and tar files
            OLDEST_IMAGE_BACKUP_FOR_ONE_CONTAINER=$(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep $CONTAINER_BACKUP_DIR_${CONTAINER_NAME} | sort  | head -n 1)  #note to when image created in docker commit command end of script fille --group by specific image name  and sort accending and get head
            docker rmi $OLDEST_IMAGE_BACKUP_FOR_ONE_CONTAINER  #delete oldest image based on date
             rm -rf  $BACKUP_FILE[0]  #delete oldest tar file based on date (BACKUP_FILE[0] shows oldest backup file in one specefic container)
        fi
        docker commit $CONTAINER_NAME "$CONTAINER_BACKUP_DIR-${CONTAINER_NAME}:V_$BACKUP_FILE_NUMBER"
        docker save "$CONTAINER_BACKUP_DIR-$CONTAINER_NAME:V_$BACKUP_FILE_NUMBER"   > "$BACKUP_MAIN_DIR/$CONTAINER_BACKUP_DIR-${CONTAINER_NAME}-V-$BACKUP_FILE_NUMBER.tar"
done


