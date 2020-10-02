#!/data/data/com.termux/files/usr/bin/ruby

require "mechanize"
require "uri"
require "json"
require "thread/pool"
#local sayang
require_relative "module/get"
require_relative "module/post"


BASEURL = URI::parse("https://mbasic.facebook.com")
BROWSER = Mechanize.new { |br| 
		br.request_headers["User-Agent"] = "Mozilla/5.0"
		br.request_headers["Connection"] = "keep-alive"
		br.request_headers["Save-Data"] = "on"
		br.request_headers["Upgrade-Insecure-Requests"] = "1"
		br.request_headers["Accept-Language"] = "id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7,ms;q=0.6"
}

class BotKontols
	def initialize
		@banner = File.read("util/logo.txt")

		if !File.exist?(".data.json") then
			self.set_kuki(self.prompt("[*] KUKI BOS: "))
		else
			data = JSON::parse(File.read(".data.json"))
			self.set_kuki(data["kuki"])
		end
	end
	def prompt(text)
		print text
		input = gets.strip
		return input
	end
	def set_kuki(kuki)
		BROWSER.request_headers["Cookie"] = kuki
		begin
			nama   = BROWSER.get(BASEURL).body.match(/Keluar\s\((.+?)\)/)
		rescue SocketError
			abort("[!] tidak ada sinyal ")
		end
		if nama.nil? then
			File.delete(".data.json")
			abort("[!] Cookie Kadaluarsa!!!")
		else
			@nama = nama[-1]
			File.open(".data.json", "w"){|f|
				f.write(JSON::pretty_generate({
					:nama => @nama,
					:kuki => kuki
				}))
			}
		end
	end
	def _get_post
		begin
			id = self.prompt("[+] ID target: ")
			jm = self.prompt("[+] jumlah post: ")
			return Get.posts(id, jm.to_i)
		rescue
			puts "[!] id tidak di temukan"
			return nil
		end		
	end
	def _get_list_fr
		jm = self.prompt("[?] jumlah fl: ")
		return Get.lists_friend(jm.to_i)
	end
	def _get_list_fm(o)
		jm = self.prompt("[?] jumlah: ")
		return Get.friends_opsi(o, jm.to_i)
	end
	def main
		while true do
			system("clear")
			puts "

   #{@banner}
   ~ user: #{@nama}

   ctrl + c untuk keluar

   01: Massal Tanggapi Postingan Target
   02: Massal Komentari Postingan Target
   03: Massal Spam Pesan Teman
   04: Massal Hapus Postingan 
   05: Massal Hapus Teman
   06: Massal Kongfirmasi Pertemanan Masuk
   07: Massal Batalkan Permintaan Pertemanan Terkirim
   08: Massal Hapus Pertemanan Masuk
   09: Massal Hapus Album
   10: Massal Keluar Group
   11: Massal Post Ke Group
   12: Bersihkan Semua Pesan

			"
			begin
				p = self.prompt("++~> ")
				if ["1", "01"].include? p then
					if !(po = self._get_post).nil? then
						rc = ["suka", "love", "haha", "marah", "peduli","sedih","wow"]
						rc.each do |i|
							puts " #{rc.index(i)+1}: #{i}"
						end
						mn = self.prompt("[?] react: ")
						po.each do |lp|
							begin
								id_s = Post.react(lp, rc[mn.to_i-1].to_s)
								puts "[#{rc[mn.to_i-1]}] #{id_s} -> #{po.index(lp)+1} \t\t"
							rescue => e
								puts "[ERROR] #{e.to_s}\t\t"
							end
						end
					end
				elsif ["2", "02"].include? p then
					if !(po = self._get_post).nil? then
						ps = self.prompt("[+] pesan: ")
						fl = self.prompt("[+] image: ")
						po.each do |lp|
							begin
								id_s = Post.coment(lp, ps, fl)
								puts "[#{ps[..6]}..] #{id_s} -> #{po.index(lp)+1} \t\t"
							rescue => e
								puts "[ERROR] #{e.to_s}\t\t"						
							end
						end
					end
				elsif ["3", "03"].include? p then
					fl = self._get_list_fr			
					
					ps = self.prompt("[?] pesan: ")
					fl.each do |li|
						Post.message(li[:link], ps)
						puts "[*] [#{ps[..10]..}] kirim ke #{li[:nama]} "
					end

				elsif ["4", "04"].include? p then
					jm = self.prompt("[?] jumlah: ")
					Get.posts("me", jm.to_i).each do |l|
						begin
							dt = Post.hapus_post(l)
							puts "[*] hapus #{dt[1]} #{dt[0]}                 "
						rescue => e
							puts "[ERROR] #{e.to_s}"
						end
					end
				elsif ["5", "05"].include? p then
					self._get_list_fr.each do |fl|
						y = Post.hapus_teman(fl[:link])
						puts "[*] removed #{y} #{fl[:nama]} "
					end
				elsif ["6", "06"].include? p then
					self._get_list_fm(1).each {|f|
						Post.friends_masuk(f[:link], "Konfirmasi")
						puts "[*] konfirmasi #{f[:nama]}  "
					}
				elsif ["7", "07"].include? p then
					self._get_list_fm(0).each {|f|
						Post.friends_masuk(f[:link], "Batalkan Permintaan")
						puts "[*] batalkan #{f[:nama]}  "
					}

				elsif ["8", "08"].include? p then
					self._get_list_fm(1).each {|f|
						Post.friends_masuk(f[:link], "Hapus Permintaan")
						puts "[*] hapus #{f[:nama]}  "
					}

				elsif ["9", "09"].include? p then
					puts "ex: album1|album2"
					fl = self.prompt("[?] filter: ")
					Get.album((fl.empty? ? "(.+?)" : "(#{fl.strip})")).each {|dt|
						dt[:data].each_with_index {|l, index|
							print "\r[*] hapus dari #{dt[:nama]} #{index +1} "
							Post.hapus_foto(l)
							puts "\r  -#{l}"
						}
						puts "[+] selesai #{dt[:nama]} #{dt[:size]}"
					}
				elsif "10" == p then
					jm = self.prompt("[?] jumlah: ")
					Get.groups(jm.to_i).each_with_index{|data, index|
						Post.keluar_group(data[:link])
						puts "[keluar] #{data[:nama]} "
					}
	
				elsif "11" == p then
					dt = Get.groups
					pl = ""
					ok = 0
					ln = Array.new
					dt.each_with_index{|data, index|
						puts "#{index + 1}: #{data[:nama]}"
						ok += 1
						if ((index+20 > dt.length) && (dt.length == index+1)) || dt.length < 20 || ok == 20 then
							ok = 0
							puts ""
							puts "[?] blank untuk continue, \033[94mOK\033[97m untuk break"
							puts "ex: 1|2|3"
							c = self.prompt("[?] pilihan: ").upcase
							if c == "OK" then
								break
							elsif !c.empty? then
								pl += "|#{c}"
							end
							system("clear")
							puts "[+] #{pl}" if !pl.empty?
							puts ""
						end
					}
					
					pl.split("|").each{|l|
						if (n = l.to_i) != 0 then
							if !(x = dt[n-1]).nil? then
								ln << x
							end
						end
					}
					if !ln.empty? then
						ps = self.prompt("[?] quote: ")
						im = Array.new
						3.times{|i|
							ik = self.prompt("[?] file#{i+1}: ")
						im << ik if File.exist?(ik)
						}
						puts ""
						ln.each_with_index{|dt, index|
							y = Post.post_grup(dt[:link], ps, im)
							puts "[#{index+1}] #{dt[:nama]} post: #{y}"
						}
					else
						puts "[!] anda tidak memilih group"
					end
				elsif "12" == p then
					Get.messages_history.each{|d|
						Post.bersihkan_pesan(d[:link])
						puts "[*] chat anda dan #{d[:nama]} terhapus .."
					}
				end
				self.prompt("\n[enter] selesai ..   ")
				
			rescue Interrupt
				abort("[CTRL+C] interrupt")
			end
		end		
	end
end


BotKontols.new.main

