#!/bin/bash

set -e
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)
BOLD=$(tput bold)

echo -e "\n ${BOLD}${GREEN}######################################### ${RESET}\n spaAcc is Installing the Environment for Kubernetes ☸️ ! \n  ${BOLD}${GREEN}######################################### ${RESET}"

echo -e "\n ${BLUE}In this process We will Check for :\n
1. Any Container Runtime \n
    - PODMAN (recomended) \n
    - Docker \n
    - RunC \n 
2. Install k8s Distro \n
    - Kind (recomended) \n
    - Minikube \n ${RESET}"

# Check if Podman is installed
if ! command -v podman &> /dev/null; then
    echo -e "\n ${BLUE} ❌ Podman is not installed. Please install Podman and try again."${RESET}
    exit 1
fi

# Check if Podman is activated

if podman info 2>&1 | grep -q "Error: unable to connect to Podman"; then
    echo -e "\n ${BLUE} ⚠️ PODMAN needs to be initialised. Initializing.."${RESET}
    # Run podman machine init
    podman machine start podman-machine-default
    podman machine init
    sleep 30

    # Wait for "Machine init complete" output
    while true; do
        if podman info 2>&1 | grep -q "Machine init complete"; then
            echo -e "\n ${BLUE} ✅ Podman is not Ready to serve 🍦 ! \n
            Checking for Kubernetes distribution."${RESET}
            break
        fi
        sleep 1
    done

fi

#### Checking for kind 

if command -v kind &> /dev/null; then
    echo -e "${BLUE} Found Kind. 😊\nlet's check if it is Active🏃🏻‍➡️..."${RESET}

    if kind get nodes 2>&1 | grep -q "No kind nodes found for cluster"; then
        echo -e "\n${BLUE}No kind Cluster found 🤔, No Worries Creating one 🛠️"${RESET}

        kind create cluster
        sleep 30

        while true; do
            if kind get nodes 2>&1 | grep -q "kind-control-plane"; then
                echo -e "\n${BLUE} ✅ Kind Cluster is not Ready to serve 🍦 ! \nChecking for Kubernetes distribution."${RESET}
                break
            fi
            sleep 1
        done
    fi
else
    echo -e "\n${BLUE} Kind Not Found. ☹️ \nKindly Install KIND. Here is the Documentation : https://kind.sigs.k8s.io/docs/user/quick-start/"${RESET}
fi

#### Checking for kubectl

if  command -v kubectl &> /dev/null; then
    echo -e "\n${BLUE}Kubectl Installed 😊\nYou are all set to Explore Containerrised app using Kind 🎬..."${RESET}

else
    echo -e "\n ${BLUE}Kubectl is not Installed. ☹️ \nPlease install it. Here is the Documentation : https://kind.sigs.k8s.io/docs/user/quick-start/"${RESET}
fi

### Prerequisite Check Done
echo -e "\n${BOLD}${BLUE} All Prerequisites are Satified ! all set to Run Bes Playbook."${RESET}

echo -e "\n${BLUE} Creating secApp Namespace"${RESET}
kubectl create ns SecApp
sleep 10

# if [ $? -eq 0 ]; then
#     echo -e "\n${BLUE}Creating Kube bench job in spaAcc Namespace"${RESET}
#     kubectl apply -f https://raw.githubusercontent.com/samirparhi-dev/kube-bench/main/job.yaml -n spaAcc
#     sleep 30
#     kubectl get jobs -n spaAcc
#     if [ $? -eq 0 ]; then
#         echo -e "\n ${BLUE}Displaying the Report. This Might Not be As fancy as you think but Useful 📊\n"${RESET}
#         kubectl get pods --selector=job-name=kube-bench -A
#         export POD_NAME=$(kubectl get pods --selector=job-name=kube-bench -A --no-headers=true | awk '{print $2}')
#         kubectl logs $POD_NAME -n spaAcc
#     fi
# else
#     echo -e "\n ${BLUE}Could not able to Create NameSpace , Try Again"${RESET}
# fi
# echo -e "\n${BOLD}${BLUE}Thank you SoMuch for Usin BeS tool.\n You can Share your thoughts and Improvements by creating PRs on out GitHub.https://github.com/Be-Secure/spaAcc"${RESET}