class Info {
 String info = '''
User Manual for Smart EVM - Electronic Voting Machine

Overview:
The Smart Electronic Voting Machine (EVM) utilizes an ESP32 microcontroller to allow voting with 8 buttons—4 for boys and 4 for girls. The system features indicator LEDs for power status, Wi-Fi connection, and vote confirmation. Votes are only sent to the database after the ESP32 resets its configuration to accept the next vote, ensuring a seamless voting experience.

1. Getting Started
1.1 Hardware Requirements:
- ESP32 Board: The core controller for the voting machine.
- USB Type-B Cable: For powering the ESP32.
- 8 Buttons:
  - 4 buttons for boys.
  - 4 buttons for girls.
- LED Indicators:
  - 1 LED for power status.
  - 1 LED for Wi-Fi connection status.
  - 8 LEDs next to the buttons for vote confirmation.
- Power Source: 5V, usually from a USB adapter or power bank.

1.2 Setting Up the Hardware:
1. Connecting the ESP32:
   - Connect the ESP32 to a power source using the USB Type-B cable.
   - The power LED will light up, indicating that the system is powered on.
   
2. Wi-Fi Connection:
   - The ESP32 will connect to the configured Wi-Fi network.
   - The Wi-Fi LED will turn on when the connection is established.

3. Button Setup:
   - The system features 8 buttons for voting, labeled as follows:
     - Boys: Boy 1, Boy 2, Boy 3, Boy 4.
     - Girls: Girl 1, Girl 2, Girl 3, Girl 4.
   - Each button has an associated LED that lights up when a vote is cast for that candidate.

2. How to Vote
2.1 Step-by-Step Voting Process:
1. Powering On:
   - Connect the ESP32 to a power source using the USB Type-B cable.
   - The power LED will indicate that the system is ready.
   
2. Wi-Fi Connection:
   - Wait for the ESP32 to connect to the Wi-Fi. The Wi-Fi LED will light up when connected.

3. Voting:
   - Select a boy: Press one of the first 4 buttons for boys. The LED next to the button will turn on, confirming the vote.
   - Select a girl: Press one of the second 4 buttons for girls. The LED next to the button will turn on, confirming the vote.
   
4. Vote Submission:
   - Once both a boy and a girl are selected, the ESP32 will reset its configuration via the web server to prepare for the next vote.
   - After the reset, the votes are sent to the database, ensuring the information is recorded securely.
   - The system will reset for the next voter.

3. Viewing Voting Results Online
3.1 Steps to Access Results:
1. Visit the Website:
   - Open your web browser and go to smartevm.in/login.
   
2. Log In:
   - Enter your ESP ID in the format NEVMxxxx (e.g., NEVM1012) to view the voting results.

4. Troubleshooting
4.1 Common Issues and Solutions:
- No Power LED:
   - Ensure the USB cable is securely connected.
   - Check that the power supply is functioning and providing 5V.
   
- Wi-Fi LED Not Turning On:
   - Verify that the Wi-Fi credentials are correctly configured on the ESP32.
   - Ensure the Wi-Fi network is available and stable.
   
- Button LEDs Not Turning On:
   - Inspect the button wiring to ensure proper connection to the ESP32.
   - Confirm that you are selecting only one candidate from each category.
   
- Unable to Log In Online:
   - Double-check the ESP ID format (e.g., NEVM1012).
   - Ensure that your internet connection is stable.

5. Important Notes:
- One Vote Per User:
   - Each voter is allowed to cast one vote for a boy and one for a girl per session. Ensure your selections are final.
   
- LED Indicators:
   - LEDs next to the buttons provide confirmation of your vote. If the LED does not illuminate after pressing, check wiring and power.
   
- Web Server Reset:
   - The ESP32’s web server resets the configuration to prepare for the next vote, ensuring no duplicate votes are recorded.
''';

}