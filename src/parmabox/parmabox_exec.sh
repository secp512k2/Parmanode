function parmabox_exec {

if [[ $1 == btcrecover ]] ; then
parmabox="btcrecover"
else
parmabox="parmabox"
fi

# Install Parmanode in Parmabox, and ParmaShell
docker exec -it -u parman $parmabox bash \
            -c "mkdir /home/parman/Desktop ; \
                curl https://parmanode.com/install.sh | sh ; \
                mkdir /home/parman/.parmanode ; \
                mkdir /home/parman/parmanode ; \
                echo \"parmashell-end\" | tee -a /home/parman/.parmanode/installed.conf >/dev/null"


# Make bashrc better
docker exec -it -u root $parmabox bash -c "echo \"function rp { cd /home/parman/parman_programs/parmanode ; ./run_parmanode.sh \$@ ; }\" | tee -a /root/.bashrc /home/parman/.bashrc" >/dev/null 2>&1
docker exec -it -u root $parmabox bash -c "echo \"source /home/parman/parman_programs/parmanode/src/ParmaShell/parmashell_functions\" | tee -a /root/.bashrc /home/parman/.bashrc" >/dev/null 2>&1
docker exec -it -u root $parmabox bash -c "sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' /root/.bashrc " >/dev/null 2>&1
docker exec -it -u root $parmabox bash -c "sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' /home/parman/.bashrc" >/dev/null 2>&1

unset parmabox
}