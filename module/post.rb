#!/data/data/com.termux/files/usr/bin/ruby

module Post
	def Post.coment(link_post, msg, image)
		form = BROWSER.get(link_post).forms_with(:action => /^\/a\/comment/).last
		form["comment_text"] = msg
		if !image.empty? then
			form = BROWSER.submit(form,form.button_with(:name => /^view_photo$/)).form
			form.file_upload_with(:name => /photo/).file_name=image.to_s
		end
		BROWSER.submit(form, form.button_with(:name => /post/))	
		return link_post.to_s.match(/story_fbid=([0-9]*)/)[1]
	end
	def Post.message(link_profile, msg)
		pg= BROWSER.get(link_profile).links_with(:text => /Pesan/)[-1].click
		form = pg.form_with(:action => /\/messages\/send\/\?icm=1/)
		form["body"] = msg.to_s
		BROWSER.submit(form, form.button_with(:name => /Send/))
	end
	def Post.react(link_post, react)
		pg = BROWSER.get(link_post)
		pg = pg.link_with(:text => /Tanggapi/).click
		pg.link_with(:text => react.capitalize).click
		return link_post.to_s.match(/story_fbid=([0-9]*)/)[1]
	end
	def Post.hapus_post(link_post)
		pg = BROWSER.get(link_post)
		begin
			er = true
			form = pg.link_with(:text => /^Hapus$/).click.form_with(:action => /^\/a\/delete/)
			BROWSER.submit(form, form.button_with(:value => /Hapus/))
		rescue
			er = false
		end
		return [link_post.to_s.match(/story_fbid=([0-9]*)/)[1], er]
	end
	def Post.hapus_teman(link_profile)
		begin
			pg = BROWSER.get(link_profile)
			form = pg.link_with(:text => /Lainnya/).click.link_with(:text => /Batalkan pertemanan/).click.form_with(:action => /^\/a\/removefriend/)
			BROWSER.submit(form, form.button_with(:name => /confirm/))
			return true
		rescue
			return false
		end
	end
	def Post.friends_masuk(link, opsi)
		BROWSER.get(link).link_with(:text => opsi).click
	end
	def Post.hapus_foto(link_foto)
		BROWSER.get(link_foto).link_with(:text => /Edit Foto/).click
		   .link_with(:text => /Hapus Foto/).click.form.submit		
	end
	def Post.keluar_group(link_group)
		BROWSER.get(link_group).link_with(:href => /view=info/, :text => /Info/).click
		       .link_with(:text => /Keluar dari Grup/).click
		       .form_with(:action => /^\/a\/group\/leave/).submit
	end
	def Post.bersihkan_pesan(link_h)
		form = BROWSER.get(link_h).form_with(:action => /^\/messages\/action_redirect/)
		BROWSER.submit(form, form.button_with(:name => /delete/)).link_with(:text => /Hapus/).click
	end
	def Post.post_grup(link_gc, ps, image=nil)
		p = BROWSER.get(link_gc).form_with(:action => /^\/composer\/mbasic/)
		if p.nil? then
			return false
		end
		form = BROWSER.submit(p, p.button_with(:value => /Lainnya/)).form_with(:action => /\/composer/)
		if !image.empty? then
			form = BROWSER.submit(form, form.button_with(:value => /Foto/)).form
			image.each_with_index do |f, i|
				form.file_upload_with(:name => /file#{i +1}/).file_name = f.to_s
			end
			form = BROWSER.submit(form, form.button_with(:name => /add_photo_done/)).form
		end
		form["xc_message"] = ps
		BROWSER.submit(form, form.buttons.last)
		return true
	end
end

