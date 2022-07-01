library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port ( 
            in_temp_naik 	      : in  STD_LOGIC;		--Tombol SUHU naik
            in_temp_turun 	    : in  STD_LOGIC;		--Tombol SUHU turun
            in_fanspeed 	      : in  STD_LOGIC;		--Tombol KECEPATAN angin AC
            in_fandir 		      : in  STD_LOGIC;		--Tombol ARAH angin AC
            Timer				        : in  STD_LOGIC;		--Tombol menyalakan TIMER
            OFF 				        : in  STD_LOGIC;		--Tombol Mematikan AC
            RESET 				      : in  STD_LOGIC;		--Internal RESET
            CLK 				        : in  STD_LOGIC;		--Internal CLOCK
            out_power 		      : out  STD_LOGIC;   --POWER		 (output)
            out_timer			      : out  integer;     --Countdown (output)
            out_temp		 	      : out  STD_LOGIC_VECTOR (1 downto 0);	      --SUHU AC 	 (output)
            out_fanspeed 	      : inout  STD_LOGIC_VECTOR (1 downto 0);     --KECEPATAN (output)
            out_fandir          : inout  STD_LOGIC_VECTOR (1 downto 0));    --ARAH angin(output)
end top;

architecture Behavioral of top is			--Inisialisasi architecture Behavioral
	signal Ticks	: integer;					--Untuk menyimpan jalannya trigger clock
	signal tTimer 	: integer;					--Menyimpan kapan AC akan mati[TIMER]
	signal cTimer 	: integer;					--Menyimpan Countdown TIMER
	signal bTimer 	: boolean;					--Menyimpan apabila TIMER sedang berjalan
	signal bTimer_after : boolean;			--Menyimpan apabila TIMER telah dijalankan
	
	type state is 									--[1/2]Membuat tipe data baru bernama state
		(s0, s1, s2, s3, nopower); 			--[2/2]dengan nilai s0, s1, s2, s3, dan nopower
	signal state_reg	: state;					--Menyimpan kondisi SUHU dan POWER saat itu juga
	signal state_next	: state;					--Menyimpan kondisi SUHU dan POWER setelahnya
	begin												--Memulai architecture main
	
		process(RESET, CLK)						--[1/2]Process akan dijalankan setiap terdapat 
												--[2/2]perubahan nilai pada port RESET dan CLK
		begin											--Memulai process
			if (RESET='1') then						--Bila Internal RESET dinyalakan, maka
				bTimer 			<= False;			--Mematikan TIMER
				Ticks 			<=0;					--Mereset kembali nilai Ticks
				tTimer 			<=0;					--Mereset kembali nilai tTimer
				cTimer 			<=0;					--Mereset countdown
				out_timer <= cTimer; 				--Mengeluarkan output countdown TIMER
				out_fanspeed 	<="00";				--Mematikan kipas AC
				out_fandir	 	<="00";				--Menutup daun AC
				state_reg 		<= nopower;			--Mematikan AC
			
			elsif (CLK'event and CLK='1') then	--RISING EDGE trigger
				if (state_next = nopower) then	--bila pada state selanjutnya AC mati, maka
					bTimer 			<= False;		--Mematikan TIMER
					Ticks 			<=0;				--Mereset kembali nilai Ticks
					tTimer 			<=0;				--Mereset kembali nilai tTimer
					out_fanspeed 	<="00";			--Mematikan kipas AC
					out_fandir	 	<="00";			--Menutup daun AC
				else 
					Ticks 	<= Ticks + 1;			--Menyimpan jalannya trigger clock, setiap 10 ns
				end if;
				
				if (Timer = '1') then		--Bila tombol TIMER ditekan, maka
					bTimer <= True;			--Timer dijalankan
					cTimer <= 9;				--Memulai Countdown [tTimer-1]
					tTimer <= Ticks + 10 ;		--[1/2]Menyimpan waktu kapan AC akan mati yaitu 
														--[2/2]10 clock trigger atau 10 ns yang akan datang
				end if;
				
				if bTimer = True then			--Bila terdapat TIMER yang berjalan
					cTimer <= cTimer - 1;		--Increment countdown TIMER AC
				end if;
				
				out_timer <= cTimer; --Mengeluarkan output countdown TIMER
				
				if (bTimer = True and Ticks = tTimer) then   --[1/2]Bila saat TIMER berjalan dan (Ticks)
																			--[2/2](Line 50) sama dengan tTimer (line 56)
					bTimer_after 	<= True;			--TIMER telah selesai dijalankan
					bTimer 			<= False;		--Mematikan TIMER
					tTimer 			<=0;				--Mereset kembali nilai tTimer
					cTimer 			<=0;				--Mereset kembali nilai countdown
					out_fanspeed 	<="00";			--Mematikan kipas AC
					out_fandir	 	<="00";			--Menutup daun AC
					state_reg 		<= nopower;		--Mematikan AC
				else
					if state_reg <= nopower and state_next = s2 then
						out_fanspeed 	<="10";			--Mematikan kipas AC
						out_fandir	 	<="10";			--Menutup daun A
					end if;
					state_reg 		<= state_next; 	--menjalankan state selanjutnya
				end if;
				
				if state_next = s2 then			--bila pada state selanjutnya AC dihidupkan, maka
					bTimer_after <= False;			--Mereset kembali nilai TIMER telah selesai dijalankan
				end if;
				
				if in_fanspeed = '1' then			--Bila tombol in_fanspeed ditekan, maka
					if state_next = nopower then		--Bila pada state selanjutnya AC dimatikan, maka				
						out_fanspeed <= "00";			--Mematikan kipas AC
					elsif out_fanspeed = "01" then	--atau apabila out_fanspeed bernilai 01, maka
						out_fanspeed <= "10";			--akan dirubah menjadi 10 (Normal)
					elsif out_fanspeed = "10" then	--atau apabila out_fanspeed bernilai 10, maka	
						out_fanspeed <= "11";			--akan dirubah menjadi 11 (Cepat)
					elsif out_fanspeed = "11" then	--atau apabila out_fanspeed bernilai 11, maka
						out_fanspeed <= "01";			--akan dirubah menjadi 01 (Pelan)
					end if;
				end if;
				
				if in_fandir = '1' then				--Bila tombol in_fandir ditekan, maka
					if state_next = nopower then		--Bila pada state selanjutnya AC dimatikan, maka				
						out_fandir 	<= "00";				--Menutup daun AC
					elsif out_fandir = "01" then		--atau apabila out_fandir bernilai 01, maka
						out_fandir <= "10";				--akan dirubah menjadi 10 (45°)
					elsif out_fandir = "10" then		--atau apabila out_fandir bernilai 10, maka
						out_fandir <= "11";				--akan dirubah menjadi 11 (75°)
					elsif out_fandir = "11" then		--atau apabila out_fandir bernilai 11, maka
						out_fandir <= "01";				--akan dirubah menjadi 01 (Otomatis)
					end if;
				end if;
			end if;
		end process;
		
		process (state_reg, OFF, in_temp_naik, --[1/2]Process akan dijalankan setiap terdapat perubahan
					in_temp_turun) 					--[2/2]nilai pada setiap port dalam parameter tersebut.
		begin
			case state_reg is							--[1/2]Switch case pada signal state_reg (untuk menentu-
															--[2/2]kan state selanjutnya.
				when nopower =>						--Ketika state_reg bernilai nopower (mati)
					if bTimer_after = True then 		--Bila Timer telah dijalankan
						state_next <= nopower;			--Mematikan AC
					elsif in_temp_naik = '1' or 
							in_temp_turun = '1'  then		--Bila salah satu tombol SUHU ditekan, maka
						state_next <= s2;						--State selanjutnya adalah normal (s2)
					else
						state_next <= state_reg;			--State selanjutnya sama dengan State saat ini.
					end if;
					
				when s0 =>
					if OFF = '1' then						--Bila tombol OFF ditekan, maka
						state_next <= nopower;			--State selanjutnya adalah AC mati.
					elsif in_temp_naik = '1' then		--Bila tombol SUHU naik ditekan, maka
						state_next <= s1;					--State selanjutnya adalah dingin (s1)
					else
						state_next <= state_reg;		--State selanjutnya sama dengan State saat ini.
					end if;
					
				when s1 =>
					if OFF = '1' then						--Bila tombol OFF ditekan, maka
						state_next <= nopower;			--State selanjutnya adalah AC mati.
					elsif in_temp_naik = '1' then		--Bila tombol SUHU naik ditekan, maka
						state_next <= s2;					--State selanjutnya adalah normal (s2)
					elsif in_temp_turun = '1' then	--Bila tombol SUHU turun ditekan, maka
						state_next <= s0;					--State selanjutnya adalah super dingin (s0)
					else
						state_next <= state_reg;		--State selanjutnya sama dengan State saat ini.
					end if;
					
				when s2 =>
					if OFF = '1' then						--Bila tombol OFF ditekan, maka
						state_next <= nopower;			--State selanjutnya adalah AC mati.
					elsif in_temp_naik = '1' then		--Bila tombol SUHU naik ditekan, maka
						state_next <= s3;					--State selanjutnya adalah hangat (s3)
					elsif in_temp_turun = '1' then	--Bila tombol SUHU turun ditekan, maka
						state_next <= s1;					--State selanjutnya adalah dingin (s1)
					else
						state_next <= state_reg;		--State selanjutnya sama dengan State saat ini.
					end if;
					
				when s3 =>
					if OFF = '1' then						--Bila tombol OFF ditekan, maka
						state_next <= nopower;			--State selanjutnya adalah AC mati.
					elsif in_temp_turun = '1' then	--Bila tombol SUHU turun ditekan, maka
						state_next <= s2;					--State selanjutnya adalah turun (s2)
					else
						state_next <= state_reg;		--State selanjutnya sama dengan State saat ini.
					end if;
			end case;
		end process;

		process (state_reg)		--Process akan dijalankan setiap terdapat perubahan state_reg
		begin
			case state_reg is 		--[1/2]Switch case pada signal state_reg (untuk menentukan
											--[2/2]state selanjutnya.
				when nopower =>				--Kondisi AC mati
					out_temp	 <= "00";  
					out_power <= '0';	
				when s0 =>						--Kondisi Super Dingin
					out_temp	 <= "00"; 
					out_power <= '1';	
				when s1 =>						--Kondisi Dingin
					out_temp	 <= "01";
					out_power <= '1';	
				when s2 =>						--Kondisi Normal
					out_temp	 <= "10"; 
					out_power <= '1';  
				when s3 =>						--Kondisi Hangat
					out_temp	 <= "11"; 
					out_power <= '1';	
			end case;
		end process;
	end Behavioral;
