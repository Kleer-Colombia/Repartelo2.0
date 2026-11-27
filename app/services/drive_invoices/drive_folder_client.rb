require 'net/http'

# Lee una carpeta de Google Drive compartida como "cualquiera con el
# vínculo", sin credenciales: lista con la vista embebida de carpetas y
# descarga con el endpoint público de descarga. Solo lectura.
class DriveFolderClient
  LIST_URL = 'https://drive.google.com/embeddedfolderview?id=%s'.freeze
  DOWNLOAD_URL = 'https://drive.usercontent.google.com/download?id=%s&export=download&confirm=t'.freeze
  MAX_REDIRECTS = 4
  MAX_DOWNLOAD_BYTES = 15 * 1024 * 1024
  ID_FORMAT = /\A[A-Za-z0-9_-]{10,}\z/

  Entry = Struct.new(:id, :name, :folder) do
    def folder?
      folder
    end

    def extension
      File.extname(name.to_s).downcase.delete('.')
    end
  end

  class Error < StandardError; end

  # [Entry] con los hijos directos de la carpeta.
  def list(folder_id)
    html = get(format(LIST_URL, checked_id(folder_id)))
    doc = Nokogiri::HTML(html.force_encoding('UTF-8'))
    doc.css('div.flip-entry').map do |entry|
      id = entry['id'].to_s.sub(/\Aentry-/, '')
      href = entry.at_css('a')&.[]('href').to_s
      name = entry.at_css('.flip-entry-title')&.text.to_s.strip
      next if id.empty? || name.empty?

      Entry.new(id, name, href.include?('/folders/'))
    end.compact
  end

  def download(file_id)
    body = get(format(DOWNLOAD_URL, checked_id(file_id)))
    # Si Google devuelve una página HTML (permiso, aviso, error) no es el archivo.
    if body.lstrip.start_with?('<!DOCTYPE html', '<html')
      raise Error, "archivo #{file_id}: Drive devolvió una página en vez del archivo (¿cambió el permiso de la carpeta?)"
    end

    body
  end

  private

  def checked_id(id)
    raise Error, "id de Drive inválido: #{id.inspect}" unless id.to_s.match?(ID_FORMAT)

    id
  end

  ALLOWED_HOST_SUFFIXES = %w[.google.com .googleusercontent.com].freeze

  # GET a Google (https), siguiendo redirecciones solo dentro de Google y
  # cortando la descarga en cuanto pasa MAX_DOWNLOAD_BYTES.
  def get(url, redirects = 0)
    uri = URI(url)
    unless uri.scheme == 'https' && ALLOWED_HOST_SUFFIXES.any? { |suffix| uri.host.to_s.end_with?(suffix) }
      raise Error, "URL no permitida: #{uri.host}"
    end

    Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
      http.request(Net::HTTP::Get.new(uri.request_uri)) do |response|
        case response
        when Net::HTTPSuccess
          return read_limited(response)
        when Net::HTTPRedirection
          raise Error, 'demasiadas redirecciones' if redirects >= MAX_REDIRECTS

          return get(URI.join(url, response['location']).to_s, redirects + 1)
        else
          raise Error, "Drive respondió #{response.code} para #{uri.path}"
        end
      end
    end
  end

  def read_limited(response)
    body = +''.b
    response.read_body do |chunk|
      body << chunk
      raise Error, "archivo de más de #{MAX_DOWNLOAD_BYTES} bytes" if body.bytesize > MAX_DOWNLOAD_BYTES
    end
    body
  end
end
