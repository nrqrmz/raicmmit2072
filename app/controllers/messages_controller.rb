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
    @message = Message.new(message_params)
    @message.challenge = @challenge
    @message.role = 'user'
    if @message.save
      if @message.file.attached?
        process_file(@message.file)
      else
        send_question
      end

      Message.create(role: "assistant", content: @response.content, challenge: @challenge)
      redirect_to challenge_messages_path(@challenge), notice: "Message was successfully created."
    else
      render :new
    end
  end

  def index
    @challenge = Challenge.find(params[:challenge_id])
  end

  private

  def send_question(model: "gpt-4.1-nano", with: {})
    @ruby_llm_chat = RubyLLM.chat(model: model)
    @response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content, with: with)
  end

  def process_file(file)
    if file.content_type == 'application/pdf'
      send_question(model: "gemini-2.0-flash", with: { pdf: @message.file.url })
    elsif file.image?
      send_question(model: "gpt-4o", with: { image: @message.file.url })
    end
  end

  def message_params
    params.require(:message).permit(:content, :file)
  end

  def challenge_context
    "Here is the context of the challenge the student is working on: \n#{@challenge.content}."
  end

  def instructions
    [SYSTEM_PROMPT, challenge_context, @challenge.system_prompt].compact.join("\n\n")
  end
end
