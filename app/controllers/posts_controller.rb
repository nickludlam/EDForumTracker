class PostsController < ApplicationController
  layout 'frontier_forums'
  QUIPS = ['Cool your jets, son!', 'You again??', 'Not so fast!', 'Haven\'t you got anything better to do?',
           'These things don\'t write themselves, you know!', 'Nope, nothing\'s changed.',
           'Maybe you could post something yourself!', 'Go stick your head in a pig!', 'Look, Thargoids!',
           'Busy day, I see.', 'No, nothing\'s changed!', 'There\'s always old episodes of Lave Radio!',
           'Nothing to see, move along.', 'This isn\'t the page you\'re looking for, move along.',
           'Try reddit.com/r/EliteDangerous instead.', '200 CR fine for loitering near this tracker!',
           'Warning! Flight Assist off!', 'Mass locked!', 'Clearly no-one\'s said \'Yaw is nerfed\' today.',
           'The mugs must be flying in Cambridge.', 'They must all be fishing on Chango.',
           'Obviously there\'s not enough discussion about \'griefing\' today.',
           'There\'s no such thing as too much play-testing!', 'Back to finding that Class A FSD upgrade, Commander!',
           'New posts have unfortunately been interdicted en route.', 'WARNING: Your reputation is too low to view new posts.',
           'Commander you do not have the correct permit to view new posts.', 'An emergency at Chango Dock has sadly delayed any new information.', 'Damnn, nothing! Why not go buy some ship paint jobs from store.zaonce.net?',
           'Supply of new dev posts has hit an all time low.', 'Due to unprecedented demand, new posts are restricted!',
           'Hostile Commander detected. Please consider some philanthropic missions!', 'Right on, Commander!',
           'The devs are hopefully busy digging a mile wide hole to add some depth.',
           'Don\'t forget to check elitedangerous.com/news/galnet too!',
           'Friendship drive charging...'
          ]
  
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
