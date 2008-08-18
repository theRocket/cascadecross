class GalleryItem < ActiveRecord::Base    
  
  class KnownExtensions
    @@extensions = {}
    class << self
      def []=(extension, content_type)
        @@extensions[extension.downcase] = content_type
      end
      def [](extension)
        @@extensions[extension.downcase] || 'Unknown'
      end
    end
  end      
  
  has_attachment :storage => :file_system,
    :path_prefix => Radiant::Config["gallery.path_prefix"],
    :processor => Radiant::Config["gallery.processor"]      
  
  belongs_to :gallery
  
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :update_by, :class_name => 'User', :foreign_key => 'update_by'
  
  has_many :infos, :class_name => "GalleryItemInfo", :dependent => :delete_all

  before_create :set_filename_as_name
  before_create :set_position
  before_create :set_extension

  before_destroy :update_positions
  
  after_attachment_saved do |item|
    item.generate_default_thumbnails if item.parent.nil?
  end
     
  def jpeg?
    not (self.content_type =~ /jpeg/).nil?
  end
  
  def absolute_path
    File.expand_path(self.full_filename)
  end
  
  def thumb(options = {})
    thumbnail_options = {}
    if options[:width] or options[:height]      
      thumbnail_options[:suffix] = "#{options[:prefix] ? options[:prefix].to_s + '_' : ''}#{options[:width]}x#{options[:height]}"
      thumbnail_options[:size] = proportional_resize(:max_width => options[:width], :max_height => options[:height])
    end
    if respond_to?(:process_attachment_with_processing) && thumbnailable? && parent_id.nil?
      tmp_thumb = find_or_initialize_thumbnail(thumbnail_options[:suffix])
      if tmp_thumb.new_record?
        logger.debug("Generating thumbnail(GalleryItem ID: #{self.id}: Prefix: #{thumbnail_options[:suffix]})")
        tmp_thumb.attributes = {
          :content_type             => content_type, 
          :filename                 => thumbnail_name_for(thumbnail_options[:suffix]), 
          :temp_path                => create_temp_file,
          :thumbnail_resize_options => thumbnail_options[:size],
          :gallery_id               => self.gallery_id,
          :position                 => nil,
          :parent_id                => self.id
        }
        callback_with_args :before_thumbnail_saved, tmp_thumb
        tmp_thumb.save!        
      else
        logger.debug("Thumbnail already exists (GalleryItem ID: #{self.id}: Prefix: #{thumbnail_options[:suffix]})")
      end
    end       
    tmp_thumb || self
  end    
  
  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
    gallery_folder = self.gallery ? self.gallery.id.to_s : self.parent.gallery.id.to_s
    File.join(RAILS_ROOT, file_system_path, gallery_folder, *partitioned_path(thumbnail_name_for(thumbnail)))
  end
  
  def last?
    self.position ==  self.gallery.items.count
  end
  
  def generate_default_thumbnails
    logger.debug "Generating default thumbnails..."
    default_thumbnails = Radiant::Config['gallery.default_thumbnails']
    if self.thumbnailable? and default_thumbnails
      default_thumbnails.split(',').each do |default_thumbnail|
        if default_thumbnail =~ /^(\w+)=(\d+)x(\d+)$/
          prefix, width, height = $1, $2, $3
          self.thumb(:width => width, :height => height, :prefix => prefix)
        end
      end
    end
  end  
  
protected    

  def set_filename_as_name
    ext = File.extname(filename)
    filename_without_extension = filename[0, filename.size - ext.size]
    self.name = filename_without_extension
  end 
  
  def set_position
    self.position = self.gallery.items.count + 1 if self.parent.nil?
  end
  
  def set_extension
    self.extension = self.filename.split(".").last.to_s.downcase
  end      
  
  def update_positions
    if self.parent.nil?
      GalleryItem.update_all("position = (position - 1)", ["position > ? AND parent_id IS NULL and gallery_id = ?", self.position, self.gallery.id])
    end
  end
  
  def proportional_resize(options = {})
    max_width = options[:max_width] ? options[:max_width].to_f : width.to_f
    max_height = options[:max_height] ? options[:max_height].to_f : height.to_f    
    aspect_ratio, pic_ratio = max_width / max_height.to_f, width.to_f / height.to_f
    scale_ratio = (pic_ratio > aspect_ratio) ?  max_width / width : max_height / height  
    [(width * scale_ratio).to_i, (height * scale_ratio).to_i]    
  end
    
end
