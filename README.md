# CNN-on-FPGA
Running a deployed Convolutional Neural Network on FPGA


## Update 09/23
- Completed C++-based algorithm verification for Hyperbolic Tangent (tanh) powered by CORDIC.
- Main concern lies in CORDIC's ability to estimate tanh(theta) where tanh(theta) is outside the range of [-2^-i, 2^-i]
  - After investigation, the reason of this issue is caused by the limitation of CORDIC algorithm. Since we restricted theta in range [-1, 1]
- This concern might be solved by double iteration:
  - Double iteration can be implemented by creating a nested loop of two iterations within each outer iteration.
  - In my code implementation, I used the aforementioned "nested loop" method to implement two-iteration CORDIC.
    - The result are quite satisfactory: After sweeping theta from -2^j to 2^j where j goes from -24 to 24 inclusive:
      - tanh(theta) estimation value are very accurate and precise until when |theta| >= 2^3, where the estimated tanh(theta) plateaus at +/-0.971075 instead of being rounded to +/-1
      - This can be significantly improved if we implement three-iteration CORDIC. (This is verified to be true)
      - **Whether three-iteration approach is efficient enough to be adopted in FPGA CNN depends on next step.**

### Next step
1. Read through the guide on CORDIC Verilog implementation. 
2. Find how to implement our two-iteration CORDIC efficiently.
3. Explore possibility of three- or even more iteration CORDIC.
4. Note that XILINX Vivado has built-in CORDIC IP that we could potentially use. Relevant links:
   1. https://www.xilinx.com/products/intellectual-property/cordic.html#overview
   2. https://docs.amd.com/v/u/en-US/cordic_ds249


## Update 10/19

Completed Environment setup for C++

### Next Step
1. Create environment to debug and simulate Verilog HDL


## Update 2024/01/11
- Completed Environment setup for Verilog HDL
- Running Verilog files:
  - Add the Verilog file names to tasks.json, replacing the entry "convolver.v"
  - Click on the search bar and click on the "Run Task" button.
  - Click on "Run Verilog"
- Simulating Verilog files:
  - Click on "Simulate Verilog"






# Methods of compiling and simulating Verilog on macOS:

As of now, **Visual Studio Code (VSCode)** does not natively include a built-in debugger specifically for **Verilog HDL**, regardless of the operating system, including macOS. However, there are extensions and third-party tools that can enable debugging and simulation capabilities for Verilog in VSCode.

Here’s how you can set up Verilog debugging capabilities in **VSCode 2 on macOS**:

---

### **1. Use Verilog Extensions**
Install extensions in VSCode for Verilog support:
- **Verilog-HDL/SystemVerilog by mshr-h**:
  - Provides syntax highlighting, linting, and basic IntelliSense for Verilog/SystemVerilog.

#### To Install:
1. Open VSCode.
2. Go to the **Extensions** marketplace (click the Extensions icon on the left toolbar).
3. Search for **"Verilog-HDL/SystemVerilog"**.
4. Click **Install**.

---

### **2. Simulation and Debugging with External Tools**
To debug Verilog, you need to use an external simulator, as VSCode itself does not provide simulation or debugging directly.

#### Popular Verilog Simulators for macOS:
1. **Icarus Verilog**:
   - A free and open-source Verilog simulator.
   - Compatible with macOS and integrates well with VSCode.

2. **ModelSim**:
   - A commercial Verilog/SystemVerilog simulator.
   - Offers robust debugging and waveform viewing but requires a license.

3. **Verilator**:
   - A free tool for synthesizable Verilog (not ideal for full simulation but excellent for linting and testing).

---

### **3. Integrate Icarus Verilog with VSCode**
#### Steps:
1. **Install Icarus Verilog**:
   - Open a terminal on macOS.
   - Use Homebrew to install Icarus Verilog:
     ```bash
     brew install icarus-verilog
     ```

2. **Create a Verilog Debug Task**:
   - In VSCode, create a `.vscode/tasks.json` file in your project directory to compile and run your Verilog code.
   - Example `tasks.json`:
     ```json
     {
       "version": "2.0.0",
       "tasks": [
         {
           "label": "Run Verilog",
           "type": "shell",
           "command": "iverilog",
           "args": ["-o", "output.vvp", "yourfile.v"],
           "group": {
             "kind": "build",
             "isDefault": true
           },
           "problemMatcher": []
         },
         {
           "label": "Simulate Verilog",
           "type": "shell",
           "command": "vvp",
           "args": ["output.vvp"],
           "group": {
             "kind": "test",
             "isDefault": true
           },
           "problemMatcher": []
         }
       ]
     }
     ```

3. **Run the Task**:
   - Open the Command Palette in VSCode (`Cmd+Shift+P`).
   - Type **"Tasks: Run Task"**.
   - Choose **"Run Verilog"** to compile or **"Simulate Verilog"** to simulate.

---

### **4. Waveform Debugging with GTKWave**
For waveform debugging:
1. Install GTKWave:
   - Use Homebrew:
     ```bash
     brew install gtkwave
     ```

2. Generate a `.vcd` (Value Change Dump) file during simulation by modifying your Verilog testbench:
   ```verilog
   initial begin
       $dumpfile("output.vcd");
       $dumpvars(0, testbench);
   end
   ```

3. After running `vvp`, open the waveform:
   ```bash
   gtkwave output.vcd
   ```

---

### **5. Advanced Debugging with ModelSim**
If you prefer a more robust debugging experience:
1. Install **ModelSim** (part of Intel Quartus or standalone).
2. Use VSCode to edit and save Verilog code.
3. Run simulations and debugging from ModelSim's GUI or CLI.

---

### **6. Optional: Verilator Integration**
For synthesizable Verilog:
1. Install **Verilator**:
   ```bash
   brew install verilator
   ```

2. Create a task in `tasks.json` to run Verilator:
   ```json
   {
     "label": "Run Verilator",
     "type": "shell",
     "command": "verilator",
     "args": ["--lint-only", "yourfile.v"],
     "problemMatcher": []
   }
   ```

3. Run the task to lint your code.

---

### **Conclusion**
While **VSCode 2 on macOS** doesn’t have a native debugger for Verilog, you can achieve debugging and simulation by integrating external tools like **Icarus Verilog**, **GTKWave**, or **ModelSim**. With extensions for syntax highlighting and tasks for simulation, VSCode can serve as an effective Verilog development environment.


