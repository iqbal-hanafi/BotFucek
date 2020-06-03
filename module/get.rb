#!/data/data/com.termux/files/usr/bin/ruby


module Get
	def Get.set_kuekis(kuki)
		BROWSER.request_headers["Cookie"] = kuki

		nama = BROWSER.get(BASEURL).body.match(/Keluar\s\((.+?)\)/)
		return nama.nil? ? nil : nama[-1]
	end
	
	def Get.posts(id="me", jumlah = nil) 
		if jumlah.nil? then
			jumlah = 10
		elsif jumlah > 500 then
			jumlah = 500
		end
		dlinks = []
		kontol = BROWSER.get(URI::join(BASEURL + id, "?v=timeline"))
		kintol = kontol.body =~ /Lihat Berita Lain/ ? "Lihat Berita Lain" : "Tampilkan lainnya"
		while dlinks.length != jumlah do
			kontol.links_with(:text => /^Berita Lengkap$/).each {|l|
				break dlinks.length == jumlah
				dlinks << (BASEURL + l.href).to_s
				print "\r[+] mengambil link p #{dlinks.length}"
			}
			begin 
				kontol = kontol.link_with(:text => /^#{kintol}$/).click
			rescue
				break
			end
		end
		puts "\n[+] selesai mengambil link p             "
		return dlinks.take(jumlah)
	end

	def Get.groups(jumlah = nil)
		datas = []
		memek = BROWSER.get(BASEURL + "groups/?seemore")
		memek.links_with(:href => /^\/groups\/\d+\?refid=\d+$/).each {|l|
			
			datas <<	
			{
					:nama => l.text,
					:link => (BASEURL + l.href).to_s

			}
			
			break if datas.length == jumlah
		}
		return datas
	end

	def Get.messages_history
		datas = []
		anjir = BROWSER.get(BASEURL + "messages/?ref_component=mbasic_home_header")
		while true do
			anjir.links_with(:href => /\/messages\/read/).each {|l|
				datas <<
				{
						:nama => l.text,
						:link => (BASEURL + l.href).to_s
				}
			}
			begin
				anjir = anjir.link_with(:text => /^Lihat Pesan Sebelumnya$/).click
			rescue
				break
			end
		end
		return datas
	end
	def Get.friends_opsi(type = 0, jumlah = nil)
		datas = []
		apsih = BROWSER.get(BASEURL + ("friends/center/requests" + (type!=1 ? "/outgoing" : "")))
		while datas.length != jumlah do
			apsih.links_with(:href => /\/friends\/hovercard/).each { |l|
				break if datas.length == jumlah
				datas <<
				{
						:nama => l.text,
						:link => (BASEURL + l.href).to_s
				}
			}
			begin
				apsih = apsih.link_with(:text => /^Lihat selengkapnya$/).click
			rescue
				break
			end
		end
		return datas
	end
	def Get.lists_friend(jumlah = nil)
		datas = []
		siapa = BROWSER.get(BASEURL + "me/friends")
		while datas.length != jumlah do
			siapa.links_with(:href => /fref=fr_tab$/).each {|l|
				break if datas.length == jumlah 
				print "\r[+] mengambil id & nama fl -> #{datas.length} "
				datas <<
				{
						:nama => l.text,
						:link => (BASEURL + l.href).to_s
				}
				
			} 
			begin
				siapa = siapa.link_with(:text => /^Lihat Teman Lain$/).click
			rescue
				break
			end
		end
		puts "\n[+] selesai mengambil id & nama fl            "
		return datas
	end
	def Get.album(filter)
		pg = BROWSER.get(BASEURL + "me/photos")
			.link_with(:href => /\/albums\/\?owner_id/).click
		datas = []
		pg.links_with(:href => /albums\/[0-9]*\//, :text => /#{filter}/).each {|dt|
			lk = {:nama => dt.text, :data => []}
			pg = BROWSER.get(BASEURL + dt.href)
			while true do
				pg.links_with(:href => /\/photo\.php/).each {|l|
					print "\r[*] #{dt.text} (#{lk[:data].length})                "
					lk[:data] << (BASEURL + l.href).to_s
				}
				begin
					pg = pg.link_with(:text => /^Lihat Foto Lainnya$/).click
				rescue
					lk[:size] = lk[:data].length
					break
				end
			end
			datas << lk
		}
		puts "\n[+] selesai .......           "		
		return datas
	end
end
