class PostsController < ApplicationController
  layout 'frontier_forums'
  QUIPS = ['Cool your jets, son!', 'You again??', 'Not so fast!', 'Haven\'t you got anything better to do?',
           'These things don\'t write themselves, you know!', 'Nope, nothing\'s changed.',
           'Maybe you could post something yourself!', 'Go stick your head in a pig!', 'Look, Thargoids!',
           'Busy day, I see.', 'No, nothing\'s changed!', 'There\'s always old episodes of Lave Radio!',
           'Nothing to seem, move along.', 'This isn\'t the page you\'re looking for, move along.',
           'Try reddit.com/r/EliteDangerous/ instead.', '100 CR fine for loitering near this tracker!',
           'Warning! Flight Assist off!', 'Mass locked!', 'Clearly no-one\'s said \'Yaw is nerfed\' today.',
           'The mugs must be flying in Cambridge.', 'They must all be fishing on Chango.',
           'Obviously there\'s not enough discussion about \'griefing\' today.',
           'There\'s no such thing as too much play-testing!' ]
  
  def index
    @authors = Author.all
    @quip = QUIPS.sample

    if session[:last_post_id]
      @posts = Post.where("forum_post_id > ?", session[:last_post_id]).order("forum_post_id DESC")
    else
      @posts = Post.all.order("forum_post_id DESC").limit(50)
    end

    session[:last_post_id] = @posts.first.forum_post_id unless @posts.empty?
  end
  
  def clear_session
    session.delete(:last_post_id)
    redirect_to :posts
  end
  
end
