module ApplicationHelper
	def qrcode_tag(text, options = {})
		::RQRCode::QRCode.new(text).as_png(options)
	end
end
