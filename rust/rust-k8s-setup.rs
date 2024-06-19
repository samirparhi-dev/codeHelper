use std::process::Command;
use std::time::Duration;
use std::thread;
use std::io::{self, Write};

fn main() {
    clear_screen();

    // Set colors
    let red = "\x1b[31m";
    let green = "\x1b[32m";
    let yellow = "\x1b[33m";
    let blue = "\x1b[34m";
    let reset = "\x1b[0m";
    let bold = "\x1b[1m";

    print_colored(&format!("\n{}{}######################################### {}{}\n spa-terminal is Installing the Environment for Kubernetes ☸️ ! \n  {}{}######################################### {}{}",
             bold, green, reset, bold, green, bold, reset));

    println!("\n{}In this process We will Check for :\n
    1. Any Container Runtime \n
        - PODMAN (recomended) \n
        - Docker \n
        - RunC \n 
    2. Install k8s Distro \n
        - Kind (recomended) \n
        - Minikube \n {}{}",
             blue, reset, reset);

    if !check_command_exists("podman") {
        println!("\n{} ❌ Podman is not installed. Please install Podman and try again.{}", blue, reset);
        return;
    }

    let podman_info = Command::new("podman").arg("info").output().unwrap_or_else(|e| panic!("Failed to execute command: {}", e));
    if podman_info.stderr != b"" {
        println!("\n{} ⚠️ PODMAN needs to be initialised. Initializing..{}", blue, reset);
        Command::new("podman").arg("machine").arg("init").output().expect("Failed to execute command");

        println!("\n{} ✅ Podman is not Ready to serve 🍦 ! \n Checking for Kubernetes distribution.{}", blue, reset);
    }

    if let Ok(_) = Command::new("kind").arg("--version").output() {
        println!("{} Found Kind. 😊\n let's check if it is Active🏃🏻‍➡️...{}", blue, reset);

        let kind_nodes = Command::new("kind").arg("get").arg("nodes").output().unwrap_or_else(|e| panic!("Failed to execute command: {}", e));
        if kind_nodes.stdout.contains(&b"No kind nodes found for cluster"[..]) {
            println!("{} No kind Cluster found 🤔, No Worries Creating one 🛠️{}", blue, reset);
            Command::new("kind").arg("create").arg("cluster").output().expect("Failed to execute command");

            println!("{} ✅ Kind Cluster is not Ready to serve 🍦 ! \n Checking for Kubernetes distribution.{}", blue, reset);
        }
    } else {
        println!("\n{} Kind Not Found. ☹️ \n Kindly Install KIND. Here is the Documentation : https://kind.sigs.k8s.io/docs/user/quick-start/{}", blue, reset);
    }

    if !check_command_exists("kubectl") {
        println!("\n{} Kubectl is not Installed. ☹️ \n Please install it. Here is the Documentation : https://kind.sigs.k8s.io/docs/user/quick-start/{}", blue, reset);
        return;
    } else {
        println!("\n{} Kubectl Installed 😊\n You are all set to Explore Containerrised app using Kind 🎬...{}", blue, reset);
    }

    println!("\n{} All Prerequisites are Satisfied! all set to Run Bes Playbook.{}", bold, reset);

    println!("\n{} Initiating BeS Playbook for KubeBench..{}", bold, reset);

    println!("\n{} Creating spa-terminal Namespace{}", blue, reset);
    execute_command("kubectl", &["create", "ns", "spa-terminal"]);

    println!("\n{} Creating Kube bench job in spa-terminal Namespace{}", blue, reset);
    execute_command("kubectl", &["apply", "-f", "https://raw.githubusercontent.com/samirparhi-dev/kube-bench/main/job.yaml", "-n", "spa-terminal"]);
    thread::sleep(Duration::from_secs(30));

    let kubectl_jobs = Command::new("kubectl").args(&["get", "jobs", "-n", "spa-terminal"]).output().unwrap_or_else(|e| panic!("Failed to execute command: {}", e));
    if kubectl_jobs.stdout.contains(&b"Completed"[..]) {
        println!("\n {} Displaying the Report. This Might Not be As fancy as you think but Useful 📊\n{}", blue, reset);
        execute_command("kubectl", &["get", "pods", "--selector=job-name=kube-bench", "-A"]);
        let pod_name = execute_command_output("kubectl", &["get", "pods", "--selector=job-name=kube-bench", "-A", "--no-headers=true"]).trim().to_string();
        execute_command("kubectl", &["logs", "-n", "spa-terminal", &pod_name]);
    } else {
        println!("\n {} Could not able to Create NameSpace , Try Again{}", blue, reset);
    }

    println!("\n{} Thank you SoMuch for Using BeS tool.\n You can Share your thoughts and Improvements by creating PRs on out GitHub.https://github.com/Be-Secure/spa-terminal{}", bold, reset);
}

fn clear_screen() {
    if let Err(_) = Command::new("clear").status() {
        println!("Failed to clear screen");
    }
}

fn print_colored(text: &str) {
    print!("{}", text);
    io::stdout().flush().unwrap();
}

fn check_command_exists(cmd: &str) -> bool {
    Command::new(cmd).arg("--version").output().is_ok()
}

fn execute_command(cmd: &str, args: &[&str]) {
    let _ = Command::new(cmd).args(args).output().unwrap_or_else(|e| panic!("Failed to execute command: {}", e));
}

fn execute_command_output(cmd: &str, args: &[&str]) -> String {
    let output = Command::new(cmd).args(args).output().unwrap_or_else(|e| panic!("Failed to execute command: {}", e));
    String::from_utf8_lossy(&output.stdout).to_string()
}
