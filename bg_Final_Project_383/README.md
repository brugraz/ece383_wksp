### Final Project: Dual-Tone Multi-Frequency Detector, C2C Bruno Graziano, ECE 383

#### Proposal
The objective is to build a portable and standards-compliant dual-tone multi-frequency (DTMF) listener and alpha-numeric T9-type text editor (or, at least, a numeric-only entry system like on a landline) in order to communicate by text through sound. This is also to practice building with documentational clarity, modularity, and with user-configuration in mind.

<img width="520" height="266" alt="image" src="https://github.com/user-attachments/assets/da0e78fc-f273-4f3f-8e81-124df8ee4556" />
High-level architecture of the DTMF detector.
<br/><br/>
The Nexus Video's on-board DSP (digital signal processing) will be used in the calculations (repeated multiplication) required to discern the incoming DTMF, even if no "DSP" module is explicitly instantiated in the VHDL. The dotted lines are to say that at least one of these connected display devices would be integrated. A microphone will also be used, integrated as an analog audio source.

#### Detailed Architecture and Sub-System Design

<img width="2400" height="1800" alt="level1shallownew" src="https://github.com/user-attachments/assets/cdb858fc-d3f1-4cf9-8db3-0e8990dbc227" />
Here is the proposed architecture with all planned modules (Frequency Discern, T9, and Display Logic). See how the two large modules divide into each's own datapath and control. "Tone Found?" is a bit expressing whether a DTMF tone (again, two specific frequencies) is currently being reliably detected from the audio input... or in short, whether someone is currently pressing a key at all. The decision for what to implement for the display and efforts towards T9 alpha-numeric entry were to be deferred until after the Frequency Discern unit was finished, and since the Frequency Discern unit is not fully working, those following modules were passed over, and LEDs were implemented to display the current detected key.
<br/><br/>

<img width="1355" height="1289" alt="freqdisc drawio (1)" src="https://github.com/user-attachments/assets/aa85b264-fb2c-49bd-ad23-2bc30620584c" />
An updated and lower level diagram of the entire project.

The "Found Tone" is 4 bits representing the value of a key, following the diagram below:
<img width="668" height="353" alt="keypad" src="https://github.com/user-attachments/assets/84f30301-74c1-4836-8ab7-8477e90b74b8" />







\includegraphics[width=1\textwidth]{level1deep}

\pagebreak

\section{Calculations, Analysis, Drawings.}
\[s = x[n] + 2\cos(\omega)s[n-1] - s[n-2]\]

when \[\omega = 2\pi \frac{f_{Target}}{F_{Sample}} = 2\pi f_{Target}T_{s}\]

as discrete time (for sampling) is represented as
\[t = nT_{s} = \frac{n}{F_{Sample}}\]

and the power calculation is
\[s[n-1]^2 + s[n-2]^2 - 2s[n-1]s[n-2]\cos(\omega)\]

To find whether a desired frequency is detected in a signal input, you can do a discrete kind of Fourier transform that looks like a summation of samples, with 'n' being the current address in the BRAM, and 'x' being the value of the current sample:
\[ \sum_{n=0}^{\# addresses} x e^{j2\pi f_{desired}t} \] 
That is, to multiply each sample by a sinusoud of whose frequency is the desired. The trigonometric identity
\[A\cos(listened freq)B\cos(desired freq) = \frac{AB}{2}\cos(listened - desired) + \frac{AB}{2}\cos(listened + desired)\] \[\sin(2)\]
shows that how close the tested and desired frequencies are is how close the result is to having a frequency of 0 Hz seen in the first term where the result sinusoid has a frequency of the difference between the listened and desired. Not too much attention should be paid to the coefficients for our sake. The added sinusoid of the listened frequency plus the desired frequency is a feature of modulation that is unhelpful to us and should be filtered out afterwards with a LPF.
Then in addition to a cosine, we will add an imaginary sine to the multiplication (per each sample) to come up with
\[\sum_{n=0}^{\# addresses}sample  \cos(2\pi f_{desired} \frac{address}{\# addresses}) + j\sin(2\pi f_{desired} \frac{address}{\# addresses}) \]
which is a phasor. It will provide a scalar number describing the "correlation" between the asked DTMF tone from each of the eight multipliers (or "correlators") and the real sound coming into the microphone recieved by the correlators from the audio codec. The math above can be done beforehand and saved into a lookup table - two tables per DTMF frequency, so 16 LUTs, one for the cosine and one for the sine.

\[t = nT = \frac{n}{f_s}\]
then \[\cos(2\pi ft)\] becomes \[\cos(2\pi \frac{f}{f_s}n)\]

\section{Milestone I}

\section{Milestone II}

\section{Updated Functionality \& Requirements}
It will be required to discern incoming DTMF sounds for the user to be able to enter something into the system. That is what "Find frequencies" and "User entry" points mean below. Any display beyond the Bare Functionality can be done with the on-board OLED or on VGA.

\subsection{Required, or Bare Functionality}
\begin{itemize}
\item Find frequencies: Use Nexus Video on-board DSP to listen to and identify the sixteen DTMF keys by their tones coming as an audio input. Also discern when there is a break in a tone. 
\item User entry: Use the UART or LEDs to display the value.
\end{itemize}

\subsection{'B' Functionality}
\begin{itemize}
\item Find frequencies: Same as required in bare functionality
\item User entry: Allow key typing where each discerned number is appended to a displayed string (UART, OLED or VGA). Do not need to repeat keypresses while a key is held down.
\end{itemize}

\subsection{'C' Functionality}
\begin{itemize}
\item Find frequencies: Same as required in bare functionality
\item User entry: Use OLED or VGA. Add T9 style typing for a user to enter alpha-numeric messages. Add a navigation mode.
\end{itemize}
Bonus: Print to USB acting as an HID-compliant USB keyboard. To show current entry options (in T9 they are not to be printed for real) they must be printed for real and spoofed as T9 through the USB standard maybe by hardcoding a backspace.

\pagebreak

scrap notes

each module is a device now, like an actuator, a chip, sensor. boundary system or something idk read the York's guidelines.
The outputs of the filter shall be (1) a vector 0-15 (4 bit) denoting the key heard, and (2) a bit denoting whether a key is currently heard or not. Rapid presses shall be broken ("inactive") in between each heard press using this bit to distinguish between "clicks." Both the bit and the vector are inputs to the T9.
T9: Be able to type numbers 0-9, *,  (that is, have a fully functional numeric-only mode). The outputs are (1) an 8-bit vector of ASCII for the current arrived key, with a special key like NULL (0x0) to say nothing is being typed and (2) one bit to denote when to move on to the next key. If a number is held, it shall repeat or spam like a computer keyboard does. \# key shall act as a backspace
T9: Ability to enter letters in ABC layout T9 with 0 being space and pound backspace. Can navigate up, down, left and right with landline keys 2, 8, 4, and 6 respectively. The "arrow keys" can output ASCII < > \textasciicircum and \_ (the '\_' is down) since arrows don't have ASCII values. Add punctuation to the nav menu, and let * switch back and forth from nav mode and type mode, type mode lets normal T9 entry take place.
Print: Add distinction for the cursor: the letter or space the cursor is on can be capitalized or highlighted. Navigation does not have to go beyond the OLED screen limits.
T9: Ability to enter an alternate layout like QWE(RTY, T9 version) as pre-set by user. User may set live numeric-only mode with pound during the nav menu. Navigation requirements persist
Print: Scrolls up, down, left, and right on the OLED if the cursor is about to go off the screen. That means the maximum size of the display in characters both horizontal and vertical are to be pre-set and configurable.


\end{document}
