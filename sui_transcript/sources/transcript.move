module sui_transcript::transcript {
  use sui::object::{Self, ID, UID};
  use sui::tx_context::{Self, TxContext};
  use sui::transfer; 
  use sui::event;

  struct TranscriptObject has key {
    id: UID,
    history: u8,
    math: u8,
    literature: u8
  }

  struct WrappableTranscript has key, store {
    id: UID,
    history: u8,
    math: u8,
    literature: u8,
  }

  struct Folder has key {
    id: UID,
    transcript: WrappableTranscript,
    intended_address: address
  }

  struct TeacherCap has key {
    id: UID
  }

  struct TranscriptRequestEvent has copy, drop {
    // The Object ID of the transcript wrapper
    wrapper_id: ID,
    // The requester of the transcript
    requester: address,
    // The intended address of the transcript
    intended_address: address,
  }

  fun init(ctx: &mut TxContext) {
    transfer::transfer(TeacherCap {
      id: object::new(ctx)
    }, tx_context::sender(ctx))
  }

  public entry fun create_transcript_object(_: &TeacherCap, history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
    let transcriptObject = TranscriptObject {
      id: object::new(ctx),
      history,
      math,
      literature,
    };
    transfer::transfer(transcriptObject, tx_context::sender(ctx))
  }

  public fun view_score(_: &TeacherCap, transcriptObject: &TranscriptObject): u8{
    transcriptObject.literature
  }

  public entry fun update_score(_: &TeacherCap, transcriptObject: &mut TranscriptObject, score: u8){
    transcriptObject.literature = score
  }

  public entry fun delete_transcript(_: &TeacherCap, transcriptObject: TranscriptObject){
    let TranscriptObject {id, history: _, math: _, literature: _ } = transcriptObject;
    object::delete(id);
  }

  public entry fun request_transcript(_: &TeacherCap, transcript: WrappableTranscript, intended_address: address, ctx: &mut TxContext){
    let folderObject = Folder {
        id: object::new(ctx),
        transcript,
        intended_address
    };
    event::emit(TranscriptRequestEvent {
        wrapper_id: object::uid_to_inner(&folderObject.id),
        requester: tx_context::sender(ctx),
        intended_address,
    });
    //We transfer the wrapped transcript object directly to the intended address
    transfer::transfer(folderObject, intended_address);
  }
  public entry fun create_wrappable_transcript_object(_: &TeacherCap, history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
    let wrappableTranscript = WrappableTranscript {
        id: object::new(ctx),
        history,
        math,
        literature,
    };
    transfer::transfer(wrappableTranscript, tx_context::sender(ctx))
  }
  public entry fun add_additional_teacher(_: &TeacherCap, new_teacher_address: address, ctx: &mut TxContext){
    transfer::transfer(
      TeacherCap {
          id: object::new(ctx)
      },
      new_teacher_address
    )
  }
}