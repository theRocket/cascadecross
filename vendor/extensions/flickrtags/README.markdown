FlickrTags
==========
FlickrTags is an extension for the [Radiant CMS][1] that provides tags for embedding [Flickr][2] slideshows (and, eventually, photographs, photosets, etc.) in pages. You can see an example of an embedded slideshow at <http://seansantry.com/portfolio/>.

The latest version is available at <http://seansantry.com/projects/flickrtags/> and from my subversion repository at <http://seansantry.com/svn/radiant/extensions/flickrtags/trunk>.
	
	
`flickr:slideshow`
==================
The `flickr:slideshow` tag embeds a slideshow into a page (using an `iframe`). Photographs for the slideshow can be selected using a Flickr photoset ID or a comma-separated list of Flickr tags. For example, the tag

	<r:flickr:slideshow user="10622160@N00" tags="portfolio"/>
	
adds a slideshow of all photographs that the Flickr user with ID 10622160@N00 has tagged as `portfolio`. This creates an `iframe` like this into the page:

	<iframe align="center" src="http://www.flickr.com/slideShow/index.gne?user_id=10622160@N00&tags=portfolio" 
    	frameBorder="0" width="500" scrolling="no" height="500"></iframe>

Note that you can't use your Flickr screen name in the `user` attribute. If you don't know your alphanumeric Flickr ID, you can look it up at <http://idgettr.com/>. 

You can combine tags into a comma-separated list to get photos that match _all_ the tags in the list. This example would create a slideshow for all photos tagged as `portfolio` and `2005`:

	<r:flickr:slideshow user="10622160@N00" tags="portfolio,2005"/>
	
You can also create a slideshow from a photoset by replacing the `tags` attribute with the `set` attribute. First, get the set ID from the photoset URL. For example, if the photoset has the URL 

	http://www.flickr.com/photos/10622160@N00/sets/548374/

the set ID is `548374`. Then, specify the set ID in the `flickr:slideshow` tag

	<r:flickr:slideshow user="10622160@N00" set="548374"/>

	
Acknowledgments
===============
Thanks to [John Long][3] for creating Radiant and to [Flickr][2] for providing a great photo-sharing community.


[1]: http://radiantcms.org
[2]: http://flickr.com
[3]: http://wiseheartdesign.com/
