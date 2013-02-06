require 'spec_helper'
require 'sphinx_environment'

describe FullTextController, :mysql, type: :controller do

  sphinx_environment(:people) do
  
    before do
      @tg_member = Fabricate(Group::TopGroup::Member.name.to_sym, group: groups(:top_group)).person
      @tg_extern = Fabricate(Role::External.name.to_sym, group: groups(:top_group)).person
      
      @bl_leader = Fabricate(Group::BottomLayer::Leader.name.to_sym, group: groups(:bottom_layer_one)).person
      @bl_extern = Fabricate(Role::External.name.to_sym, group: groups(:bottom_layer_one)).person
      
      @bg_leader = Fabricate(Group::BottomGroup::Leader.name.to_sym, group: groups(:bottom_group_one_one)).person
      @bg_member = Fabricate(Group::BottomGroup::Member.name.to_sym, group: groups(:bottom_group_one_one)).person
      
      ThinkingSphinx::Test.index
    end
      
    describe "GET index" do
      
      context "as top leader" do
        before {sign_in(people(:top_leader)) }
        
        it "finds accessible person" do
          get :index, q: @bg_leader.last_name[1..5]
          
          assigns(:people).should include(@bg_leader)
        end
        
        it "does not find not accessible person" do
          get :index, q: @bg_member.last_name[1..5]
          
          assigns(:people).should_not include(@bg_member)
        end
        
        it "does not search for too short queries" do
          get :index, q: 'e'
          
          assigns(:people).should == []
        end
      end
      
      context "as root" do
        before { sign_in(people(:root)) }
        
        it "finds every person" do
          get :index, q: @bg_member.last_name[1..5]
          
          assigns(:people).should include(@bg_member)
        end
      end
      
    end
    
    describe 'GET query' do
      
      before {sign_in(people(:top_leader)) }
              
              
      it "finds accessible person" do
        get :query, q: @bg_leader.last_name[1..5]
        
        @response.body.should include(@bg_leader.full_name)
      end
      
      it "does not find not accessible person" do
        get :query, q: @bg_member.last_name[1..5]
        
        @response.body.should_not include(@bg_leader.full_name)
      end
      
      it "finds groups" do
        get :query, q: groups(:bottom_layer_one).to_s[1..5]
        
        @response.body.should include(groups(:bottom_layer_one).to_s)
      end
    end
  
  end
  
end
