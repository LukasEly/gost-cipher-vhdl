--------------------------------------
-- Biblioteca
--------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

--------------------------------------
-- Entidade
--------------------------------------
entity tb is
end entity;

--------------------------------------
-- Arquitetura
--------------------------------------
architecture tb of tb is
  signal clk, rst : std_logic := '1';     -- inputs
  signal start, enc_dec : std_logic;
  signal data_i, data_o : std_logic_vector(63 downto 0);
  signal key_i : std_logic_vector(255 downto 0);
  signal busy, ready: std_logic; -- outputs
begin

  DUT: entity work.cripty_gost
       port map(start => start, enc_dec => enc_dec, reset => rst, clock => clk, data_i => data_i, 
                data_o => data_o, key_i => key_i, busy => busy, ready => ready);

  -- inputs
  -- 00 at 0 ns
  -- 01 at 10 ns
  -- 10 at 20 ns
  -- 11 at 30 ns
  
  clk  <= not clk after 20 ns;
  rst  <= '0';
  start <= '0', '1' after 30 ns, '0' after 100 ns, '1' after 100000 ns, '0' after 100100 ns;
  enc_dec <= '0', '1' after 40 ns, '0' after 80 ns;
  data_i <= x"A5A5A5A501234567", x"272612A5EE5D03AD" after 60000 ns;
  key_i <= x"DEADBEEF0123456789ABCDEFDEADBEEFDEADBEEF0123456789ABCDEFDEADBEEF";

end architecture;