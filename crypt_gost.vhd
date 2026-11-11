library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity cripty_gost is
    port
    (
        start   :   in  std_logic;
        enc_dec :   in  std_logic;
        data_i  :   in  std_logic_vector(63 downto 0);
        key_i   :   in  std_logic_vector(255 downto 0);
        reset   :   in  std_logic;
        clock   :   in  std_logic;
        busy    :   out std_logic;
        ready   :   out std_logic;
        data_o  :   out std_logic_vector(63 downto 0)
    );
end cripty_gost;

architecture cripty of cripty_gost is

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////|
--                                   MATRIZ DEFINICAO                                                   --|
                                                                                                        --|
type matriz is array (natural range <>, natural range <>) of std_logic_vector(7 downto 0);              --|                                                   
signal s_box : matriz(0 to 7, 0 to 15) := (                                                             --|
    ( "00000100", "00001010", "00001001", "00000010", "00001101", "00001000", "00000000", "00001110",   --|
      "00000110", "00001011", "00000001", "00001100", "00000111", "00001111", "00000101", "00000011" ), --|
    ( "00001110", "00001011", "00000100", "00001100", "00000110", "00001101", "00001111", "00001010",   --|
      "00000010", "00000011", "00001000", "00000001", "00000000", "00000111", "00000101", "00001001" ), --|
    ( "00000101", "00001000", "00000001", "00001101", "00001010", "00000011", "00000100", "00000010",   --|
      "00001110", "00001111", "00001100", "00000111", "00000110", "00000000", "00001001", "00001011" ), --|
    ( "00000111", "00001101", "00001010", "00000001", "00000000", "00001000", "00001001", "00001111",   --|
      "00001110", "00000100", "00000110", "00001100", "00001011", "00000010", "00000101", "00000011" ), --|
    ( "00000110", "00001100", "00000111", "00000001", "00000101", "00001111", "00001101", "00001000",   --|
      "00000100", "00001010", "00001001", "00001110", "00000000", "00000011", "00001011", "00000010" ), --|
    ( "00000100", "00001011", "00001010", "00000000", "00000111", "00000010", "00000001", "00001101",   --|
      "00000011", "00000110", "00001000", "00000101", "00001001", "00001100", "00001111", "00001110" ), --|
    ( "00001101", "00001011", "00000100", "00000001", "00000011", "00001111", "00000101", "00001001",   --|
      "00000000", "00001010", "00001110", "00000111", "00000110", "00001000", "00000010", "00001100" ), --|
    ( "00000001", "00001111", "00001101", "00000000", "00000101", "00000111", "00001010", "00000100",   --|
      "00001001", "00000010", "00000011", "00001110", "00000110", "00001011", "00001000", "00001100" )  --|
);                                                                                                      --|
                                                                                                        --|
--                                                                                                      --|
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////|

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|
--                                        MAQUUINA DE ESTADOS DEFINICAO                                                                                                     --|
type State is (IDLE, INICIO,                                                                                                                      -- STARTING               --| 
               ENC_FOR_INT1, ENC_GR_INIT1, ENC_TRANS_COUNT, ENC_COUNT_I_J, ENC_FOR_INT2, ENC_GR_INIT2, ENC_TRANSICTION, ENC_COUNT_I2, OP_ENCRIPT, -- ENCRIPT                --| 
               DEC_FOR_INT1, DEC_GR_INIT1, DEC_TRANS_COUNT, DEC_TRANSICTION, DEC_COUNT_I1, DEC_FOR_INT2, DEC_GR_INIT2, DEC_COUNT_I_J, OP_DECRIPT, -- DECRIPT                --|
               GR_INIT, GR_FOR, GR_FOR_OPR, GR_NI, GR_NI_S_BOX, GR_MASK1, GR_MASK2, GR_SN, GR_COUNT_K, GR_TRANSICTION, GR_FINAL_OPR, GR_R_OR_MASK, GR_CM2_R, GR_N1_CM2,             -- GOST_ROUND             --|
               VERIFY_FOR, BUG);                                                                                                              
                                                                                                                                                                            --|
signal EA, PE : State;                                                                                                                                                      --|
--                                                                                                                                                                          --|
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|

-- /////////////////////////////////////////////////////////////////////////////////////////////////|
--                                      SINAIS DEFINICAO                                          --|
                                                                                                  --|
signal for_verifier: std_logic_vector(2 downto 0);                                                --|
signal key_pos_choose: std_logic_vector(2 downto 0);                                              --|
signal reg_data_o: std_logic_vector(63 downto 0);                                                 --|
                                                                                                  --|
-- declarações gost_round                                                                         --|
                                                                                                  --|
signal SN: std_logic_vector(31 downto 0);                                                         --|
signal Ni: std_logic_vector(7 downto 0);                                                          --|
signal mask: std_logic_vector(31 downto 0);                                                       --|
signal pos: natural;                                                                              --|
signal k: natural;                                                                                --|
signal nNi: natural;                                                                              --|
                                                                                                  --|
signal gr_transiction_find: std_logic;                                                            --|
                                                                                                  --|
--                                                                                                --|
                                                                                                  --|
signal count_enc_i1: std_logic_vector(1 downto 0); -- PRIMEIRO COUNT DO ENCRIPT                   --|
signal count_enc_j: std_logic_vector(2 downto 0);  -- COUNT INTERNO DO PRIMEIRO FOR DO ENCRIPWT   --|
signal count_enc_i2: std_logic_vector(2 downto 0); -- SEGUNDO COUNT DO ENCRIPT                    --|
signal count_k: std_logic_vector(2 downto 0);      -- COUNT DO GOST_ROUND                         --|
signal count_dec_i1: std_logic_vector(2 downto 0); -- PRIMEIRO COUNT DO DECRIPT                   --|
signal count_dec_i2: std_logic_vector(1 downto 0); -- SEGUNDO COUNT DO DECRIPT                    --|
signal count_dec_j: std_logic_vector(2 downto 0);  -- COUNT INTERNO DO SEGUNDO FOR DO DECRIPT     --|
signal N1: std_logic_vector(31 downto 0);                                                         --|
signal N2: std_logic_vector(31 downto 0);                                                         --|
signal CM1: std_logic_vector(31 downto 0);                                                        --|
signal CM2: std_logic_vector(31 downto 0);                                                        --|
signal R: std_logic_vector(31 downto 0);                                                          --|
signal CM1_aux: std_logic_vector(31 downto 0);                                                    --|
                                                                                                  --|
--                                                                                                --|
-- /////////////////////////////////////////////////////////////////////////////////////////////////|

-- /////////////////////////////////// MÁQUINA DE ESTADOS ///////////////////////////////////////////

begin
    process (clock, reset)  
    begin
      if reset = '1' then  -- Estado inicial
        EA <= IDLE;
      elsif rising_edge(clock) then  
        EA <= PE;
      end if;
    end process;
  
    process (EA, start, enc_dec)
    begin
      case EA is

        -- STARTING
        
        when IDLE =>
            if (start = '1') then
                PE <= INICIO;
            else
                PE <= IDLE;
            end if;

        when INICIO =>
            if (enc_dec = '1') then
                PE <= ENC_FOR_INT1;
            else
              PE <= DEC_FOR_INT1;
            end if;

        -- ENCRIPT

        when ENC_FOR_INT1 =>
            PE <= ENC_GR_INIT1;

        when ENC_GR_INIT1 =>
            if (count_enc_i1 = "11") and (count_enc_j = "000") then PE <= ENC_FOR_INT2;
            elsif (count_enc_j = "111") then PE <= ENC_TRANS_COUNT;
            else PE <= ENC_COUNT_I_J;
            end if;         

        when ENC_TRANS_COUNT =>
            PE <= GR_INIT;
        
        when ENC_COUNT_I_J =>
            PE <= GR_INIT;

        when ENC_FOR_INT2 =>
            PE <= ENC_GR_INIT2;
        
        when ENC_GR_INIT2 =>
            if(count_enc_i2 = "000") then PE <= ENC_TRANSICTION;
            else PE <= ENC_COUNT_I2;
            end if;

        when ENC_COUNT_I2 =>
            PE <= GR_INIT;

        when ENC_TRANSICTION =>
            PE <= GR_INIT;

        when OP_ENCRIPT =>
            PE <= IDLE;

        -- GOST_ROUND

        when GR_INIT =>
            PE <= GR_FOR;

        when GR_FOR =>
            PE <= GR_FOR_OPR;

        when GR_FOR_OPR =>
            if(count_k = "111") then PE <= GR_TRANSICTION;
            else PE <= GR_NI;
            end if;

        when GR_NI =>
            PE <= GR_NI_S_BOX;

        when GR_NI_S_BOX =>
            PE <= GR_MASK1;

        when GR_MASK1 =>
            PE <= GR_MASK2;

        when GR_MASK2 =>
            PE <= GR_SN;

        when GR_SN =>
            PE <= GR_COUNT_K;

        when GR_COUNT_K =>
            if(gr_transiction_find = '1') then PE <= GR_FINAL_OPR;
            else PE <= GR_FOR_OPR;
            end if;
            
        when GR_TRANSICTION =>
            PE <= GR_NI;
        
        when GR_FINAL_OPR => 
            PE <= GR_R_OR_MASK;

        when GR_R_OR_MASK =>
            PE <= GR_CM2_R;

        when GR_CM2_R =>
            PE <= GR_N1_CM2;

        when GR_N1_CM2 =>
            PE <= VERIFY_FOR;    

        -- VERIFY

        when VERIFY_FOR =>
            if (for_verifier = "000") then PE <= ENC_GR_INIT1;
            elsif (for_verifier = "001") then PE <= ENC_GR_INIT2;
            elsif (for_verifier = "010") then PE <= DEC_GR_INIT1;
            elsif (for_verifier = "011") then PE <= DEC_GR_INIT2;
            elsif (for_verifier = "100") then PE <= OP_ENCRIPT;
            elsif (for_verifier = "101") then PE <= DEC_FOR_INT2;
            else PE <= BUG;
            end if;

        when BUG =>
            PE <= IDLE;

        -- DECRIPT
        
        when DEC_FOR_INT1 =>
            PE <= DEC_GR_INIT1;

        when DEC_GR_INIT1 =>
            if(count_dec_i1 = "111") then PE <= DEC_TRANSICTION;
            else PE <= DEC_COUNT_I1;
            end if;

        when DEC_COUNT_I1 =>
            PE <= GR_INIT;

        when DEC_TRANSICTION =>
            PE <= GR_INIT;

        when DEC_FOR_INT2 =>
            PE <= DEC_GR_INIT2;

        when DEC_GR_INIT2 =>
            if(count_dec_i2 = "11" and count_dec_j = "111") then PE <= OP_DECRIPT;
            elsif (count_dec_j = "000") then PE <= DEC_TRANS_COUNT;
            else PE <= DEC_COUNT_I_J;
            end if;

        when DEC_COUNT_I_J =>
            PE <= GR_INIT;

        when DEC_TRANS_COUNT =>
            PE <= GR_INIT;

        when OP_DECRIPT =>
            PE <= IDLE;

        -- DEFAULT
        
        when others =>
          PE <= IDLE;
      end case;
    end process;

-- //////////////////////////////////////////////////////////////////////////////////////////////////

-- ///////////////////////////////// LÓGICA DE COUNTS/ALGORITMO /////////////////////////////////////

    process(clock, reset)
    begin
        if(reset = '1') then 
            count_enc_i1 <= (others => '0');
            count_enc_j <= (others => '0');
            count_enc_i2 <= (others => '0');
            count_k <= (others => '0');
            count_dec_i1 <= (others => '0');
            count_dec_i2 <= (others => '0');
            count_dec_j <= (others => '0');
            Ni <= (others => '0');
            SN <= (others => '0');
            mask <= (others => '0');
            CM1 <= (others => '0');
            reg_data_o <= (others => '0');
            for_verifier <= (others => '0');
            CM1_aux <= (others => '0');

        elsif rising_edge(clock) then

            -- START

            if (EA = IDLE) then
                SN <= (others => '0');
                Ni <= (others => '0');
                mask <= (others => '0');
                N1 <= (others => '0');
                N2 <= (others => '0');
                CM1 <= (others => '0');
                CM1_aux <= (others => '0');
                CM2 <= (others => '0');
                R <= (others => '0');

            -- //////////////////// ENCRIPT //////////////////// -- 

            elsif (EA = ENC_FOR_INT1) then
                count_enc_i1 <= "00";
                count_enc_j <= "000";
                for_verifier <= "000";
                N1 <= data_i(31 downto 0);
                N2 <= data_i(63 downto 32);

            elsif (EA = ENC_COUNT_I_J) then
                key_pos_choose <= count_enc_j;
                count_enc_j <= count_enc_j + "001";

            elsif (EA = ENC_TRANS_COUNT) then
                key_pos_choose <= count_enc_j;
                count_enc_i1 <= count_enc_i1 + "01";
                count_enc_j <= count_enc_j + "001";

            elsif (EA = ENC_FOR_INT2) then
                count_enc_i1 <= count_enc_i1 + "01";
                count_enc_i2 <= "111";
                for_verifier <= "001";

            elsif (EA = ENC_COUNT_I2) then
                key_pos_choose <= count_enc_i2;
                count_enc_i2 <= count_enc_i2 - "001";

            elsif (EA = ENC_TRANSICTION) then
                key_pos_choose <= count_enc_i2;
                count_enc_i2 <= count_enc_i2 - "001";
                for_verifier <= "100";

            elsif (EA = OP_ENCRIPT) then
                reg_data_o <= N1 & N2;
                

            -- //////////////////// DECRIPT //////////////////// -- 
                
            elsif (EA = DEC_FOR_INT1) then
                count_dec_i1 <= "000";
                for_verifier <= "010";
                N1 <= data_i(31 downto 0);
                N2 <= data_i(63 downto 32);
            
            elsif (EA = DEC_COUNT_I1) then
                key_pos_choose <= count_dec_i1;
                count_dec_i1 <= count_dec_i1 + "001";

            elsif (EA = DEC_TRANSICTION) then
                key_pos_choose <= count_dec_i1;
                count_dec_i1 <= count_dec_i1 + "001";
                for_verifier <= "101";

            elsif (EA = DEC_FOR_INT2) then
                count_dec_i2 <= "00";
                count_dec_j <= "111";
                for_verifier <= "011";

            elsif (EA = DEC_COUNT_I_J) then
                key_pos_choose <= count_dec_j;
                count_dec_j <= count_dec_j - "001";

            elsif (EA = DEC_TRANS_COUNT) then
                key_pos_choose <= count_dec_j;
                count_dec_i2 <= count_dec_i2 + "01";
                count_dec_j <= count_dec_j - "001";
                
            elsif (EA = OP_DECRIPT) then
                count_dec_i2 <= count_dec_i2 + "01";
                reg_data_o <= N1 & N2;

            -- //////////////////// GOST_ROUND //////////////////// -- 

            elsif (EA = GR_INIT) then
                if pos = 7 then
                    CM1 <= (N1 + key_i(31 downto 0));
                elsif pos = 6 then
                    CM1 <= (N1 + key_i(63 downto 32));
                elsif pos = 5 then
                    CM1 <= (N1 + key_i(95 downto 64));
                elsif pos = 4 then
                    CM1 <= (N1 + key_i(127 downto 96));
                elsif pos = 3 then
                    CM1 <= (N1 + key_i(159 downto 128));
                elsif pos = 2 then
                    CM1 <= (N1 + key_i(191 downto 160));
                elsif pos = 1 then
                    CM1 <= (N1 + key_i(223 downto 192));
                elsif pos = 0 then
                    CM1 <= (N1 + key_i(255 downto 224));
                end if;                        
                SN <= (others => '0');

            elsif (EA = GR_FOR) then
                count_k <= "000";


            elsif (EA = GR_FOR_OPR) then
                CM1_aux <= std_logic_vector(shift_right(unsigned(CM1), (4*(7-k)))(CM1'range));
            
            elsif (EA = GR_NI) then
                Ni <= "0000" & CM1_aux(3 downto 0);
                
            elsif (EA = GR_NI_S_BOX) then
                Ni <= s_box(k, nNi);
                mask <= (others => '0');
            
            elsif (EA = GR_MASK1) then
                mask <= mask or ("000000000000000000000000" & Ni);

            elsif (EA = GR_MASK2) then 
                mask <= std_logic_vector(shift_left(unsigned(mask), (28 - (4*k)))(mask'range));

            elsif (EA = GR_SN) then
                SN <= SN or mask;

            elsif (EA = GR_COUNT_K) then
                if(gr_transiction_find = '1') then
                    gr_transiction_find <= '0';
                end if;
                count_k <= count_k + "001";
            
            elsif (EA = GR_TRANSICTION) then
                CM1_aux <= std_logic_vector(shift_right(unsigned(CM1), (4*(7-k)))(CM1'range));
                gr_transiction_find <= '1';
            
            elsif (EA = GR_FINAL_OPR) then
                R <= SN;
                mask <= std_logic_vector(shift_left(unsigned(SN), 11)(SN'range));

            elsif (EA = GR_R_OR_MASK) then
                R <=  std_logic_vector(shift_right(unsigned(SN), 21)(SN'range)) or mask;

            elsif (EA = GR_CM2_R) then
                CM2 <= R xor N2;
                N2 <= N1;

            elsif (EA = GR_N1_CM2) then
                N1 <= CM2;

            end if;

        end if;
    end process;     
    
-- //////////////////////////////////////////////////////////////////////////////////////////////////

-- /////////////// ASSIGNS ///////////////

pos <= to_integer(unsigned(key_pos_choose));
k <= to_integer(unsigned(count_k));
nNi <= to_integer(unsigned(Ni));

-- ///////////////////////////////////////

-- ///////////// BUSY/READY //////////////

data_o <= reg_data_o;

    process(EA)
    begin
        case (EA) is
            when IDLE =>
                busy <= '0';
                ready <= '1';

            when others =>
                busy <= '1';
                ready <= '0';

        end case;

    end process;

end architecture cripty;

-- ///////////////////////////////////////