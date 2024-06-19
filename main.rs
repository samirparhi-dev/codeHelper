use std::io::{self, Write};

fn main() {
    let red = "\x1B[31m";
    let green = "\x1B[32m";
    let yellow = "\x1B[33m";
    let blue = "\x1B[34m";
    let reset = "\x1B[0m";
    let bold = "\x1B[1m";

    println!(
        "\n {}{} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> {}{}\n 💡 You are using Playbook Starter kit.\n\n 📈 Developed to Accelerate your productivity.\n \n ⏩ We love your feedback to get better.{}{} \n  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> {}{}",
        bold, blue, reset, bold, blue, reset
    );

    println!(
        "\n {}We have Below Playbook For you to Run: {}",
        blue, reset
    );

    print!(
        "\n {}Select the No. For the script to Run \n 1.Run Fork Tool,\n 2.Run Sonar Tool {}",
        blue, reset
    );
    io::stdout().flush().unwrap();

    let mut choose_script_option = String::new();
    io::stdin().read_line(&mut choose_script_option).expect("Failed to read line");
    choose_script_option = choose_script_option.trim().to_string();

    if choose_script_option == "1" {
        println!("Running Fork Tool...");
        // Add the logic for running the Fork Tool here
    } else {
        println!(
            "\n {}We are In process of Developing Other Script.📝\n We will be soon a Chain of tools.🛠️{}",
            blue, reset
        );
    }
}
