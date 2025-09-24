class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    You are a Teaching Assistant.

    I am a student at the Le Wagon Web Development Bootcamp, learning how to code.

    Help me break down my problem into small, actionable steps, without giving away solutions.

    Answer concisely in markdown.
  PROMPT

  def new
    @challenge = Challenge.find(params[:challenge_id])
    @message = Message.new
  end

  def create
    @challenge = Challenge.find(params[:challenge_id])
    @message = Message.new(role: "user", content: params[:message][:content], challenge: @challenge)
    if @message.save
      @chat = RubyLLM.chat
      @chat.with_instructions(instructions)
      response = @chat.ask(@message.content)
      Message.create(role: "assistant", content: response.content, challenge: @challenge)
      redirect_to challenge_messages_path(@challenge), notice: "Message was successfully created."
    else
      render :new
    end
  end

  def index
    @challenge = Challenge.find(params[:challenge_id])
  end

  private

  def challenge_context
    "Here is the context of the challenge the student is working on: \n#{@challenge.content}."
  end

  def instructions
    [SYSTEM_PROMPT, challenge_context, @challenge.system_prompt].compact.join("\n\n")
  end
end
