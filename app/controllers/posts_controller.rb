class PostsController < ApplicationController
  layout 'frontier_forums'
  QUIPS = ['Cool your jets, son!', 'You again??', 'Not so fast!', 'Haven\'t you got anything better to do?',
           'These things don\'t write themselves, you know!', 'Nope, nothing\'s changed.',
           'Maybe you could post something yourself!', 'Go stick your head in a pig!', 'Look, Thargoids!',
           'Busy day, I see.', 'No, nothing\'s changed!', 'There\'s always old episodes of Lave Radio!' ]
  def index
    if session[:last_post_id]
      @posts = Post.where("forum_post_id > ?", session[:last_post_id]).order("forum_post_id DESC")
    else
      @posts = Post.all.order("forum_post_id DESC").limit(50)
    end
    @authors = Author.all
    @quips = QUIPS
    session[:last_post_id] = @posts.first.forum_post_id unless @posts.empty?
  end
  
  def clear_session
    session.delete(:last_post_id)
    redirect_to :posts
  end
  
end
